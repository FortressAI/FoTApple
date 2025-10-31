#!/usr/bin/env node
/**
 * QFOT MCP Server
 * 
 * Model Context Protocol server for QFOT blockchain integration
 * Enables Claude Desktop, Cursor, Cline, and all MCP-compatible AI agents
 * to query and validate facts on the QFOT blockchain.
 * 
 * Installation:
 *   npm install @modelcontextprotocol/sdk axios
 * 
 * Usage:
 *   node qfot_mcp_server.js
 * 
 * Configuration in Claude Desktop:
 *   ~/.config/claude/claude_desktop_config.json
 */

import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
} from "@modelcontextprotocol/sdk/types.js";
import axios from "axios";

// Configuration
const QFOT_API_URL = process.env.QFOT_API_URL || "http://94.130.97.66/api";
const QFOT_ALIAS = process.env.QFOT_ALIAS || "@Domain-Packs.md";
const QFOT_WALLET_ID = process.env.QFOT_WALLET_ID || "";

// Create server instance
const server = new Server(
  {
    name: "qfot",
    version: "1.0.0",
  },
  {
    capabilities: {
      tools: {},
    },
  }
);

// Helper function for API calls
async function qfotAPICall(endpoint: string, method: string = "GET", data?: any) {
  try {
    const response = await axios({
      method,
      url: `${QFOT_API_URL}${endpoint}`,
      data,
      timeout: 10000,
    });
    return response.data;
  } catch (error: any) {
    throw new Error(`QFOT API Error: ${error.message}`);
  }
}

// Tool definitions
server.setRequestHandler(ListToolsRequestSchema, async () => {
  return {
    tools: [
      {
        name: "query_facts",
        description: "Search for validated facts on the QFOT blockchain. Returns cryptographically-proven, expert-validated knowledge across medical, legal, education, and general domains.",
        inputSchema: {
          type: "object",
          properties: {
            query: {
              type: "string",
              description: "Search query (semantic search enabled)",
            },
            domain: {
              type: "string",
              enum: ["medical", "legal", "education", "general", "all"],
              description: "Domain to search in",
              default: "all",
            },
            limit: {
              type: "number",
              description: "Maximum number of results",
              default: 10,
            },
            minConfidence: {
              type: "number",
              description: "Minimum validation confidence (0-1)",
              default: 0.7,
            },
          },
          required: ["query"],
        },
      },
      {
        name: "get_fact",
        description: "Retrieve a specific fact by ID with full validation history and cryptographic proof",
        inputSchema: {
          type: "object",
          properties: {
            factId: {
              type: "string",
              description: "Fact ID to retrieve",
            },
          },
          required: ["factId"],
        },
      },
      {
        name: "validate_fact",
        description: "Validate or refute a fact on the blockchain (requires QFOT stake)",
        inputSchema: {
          type: "object",
          properties: {
            factId: {
              type: "string",
              description: "Fact ID to validate/refute",
            },
            action: {
              type: "string",
              enum: ["validate", "refute"],
              description: "Validation action",
            },
            stake: {
              type: "number",
              description: "QFOT stake amount",
              default: 30.0,
            },
            evidence: {
              type: "string",
              description: "Supporting evidence or reasoning",
            },
          },
          required: ["factId", "action", "evidence"],
        },
      },
      {
        name: "submit_fact",
        description: "Submit a new fact to the QFOT blockchain (earn 70% of all future query fees!)",
        inputSchema: {
          type: "object",
          properties: {
            content: {
              type: "string",
              description: "Fact content (max 500 chars)",
            },
            domain: {
              type: "string",
              enum: ["medical", "legal", "education", "general"],
              description: "Knowledge domain",
            },
            stake: {
              type: "number",
              description: "Initial QFOT stake",
              default: 30.0,
            },
          },
          required: ["content", "domain"],
        },
      },
      {
        name: "get_tokenomics",
        description: "Get user's earnings, statistics, and token economics data",
        inputSchema: {
          type: "object",
          properties: {
            alias: {
              type: "string",
              description: "User alias (e.g., @Domain-Packs.md)",
              default: QFOT_ALIAS,
            },
          },
          required: [],
        },
      },
      {
        name: "get_network_stats",
        description: "Get live QFOT blockchain network statistics",
        inputSchema: {
          type: "object",
          properties: {},
          required: [],
        },
      },
      {
        name: "get_top_facts",
        description: "Get top-earning or most-queried facts on the network",
        inputSchema: {
          type: "object",
          properties: {
            sortBy: {
              type: "string",
              enum: ["queries", "earnings", "recent"],
              description: "Sort criteria",
              default: "queries",
            },
            domain: {
              type: "string",
              enum: ["medical", "legal", "education", "general", "all"],
              description: "Filter by domain",
              default: "all",
            },
            limit: {
              type: "number",
              description: "Number of results",
              default: 10,
            },
          },
          required: [],
        },
      },
    ],
  };
});

// Tool handlers
server.setRequestHandler(CallToolRequestSchema, async (request) => {
  const { name, arguments: args } = request.params;

  try {
    switch (name) {
      case "query_facts": {
        const { query, domain = "all", limit = 10, minConfidence = 0.7 } = args as any;
        
        const endpoint = `/facts/search?query=${encodeURIComponent(query)}&limit=${limit}`;
        const results = await qfotAPICall(endpoint);
        
        // Filter by domain and confidence
        let facts = results.results || [];
        if (domain !== "all") {
          facts = facts.filter((f: any) => f.domain === domain);
        }
        facts = facts.filter((f: any) => (f.validation_confidence || 0) >= minConfidence);
        
        return {
          content: [
            {
              type: "text",
              text: JSON.stringify({
                query,
                resultsCount: facts.length,
                facts: facts.map((f: any) => ({
                  id: f.id,
                  content: f.content,
                  domain: f.domain,
                  creator: f.creator,
                  confidence: f.validation_confidence || 0,
                  queries: f.query_count || 0,
                  stake: f.stake_amount,
                  created: f.created_at,
                })),
              }, null, 2),
            },
          ],
        };
      }

      case "get_fact": {
        const { factId } = args as any;
        
        const fact = await qfotAPICall(`/facts/${factId}`);
        
        return {
          content: [
            {
              type: "text",
              text: JSON.stringify({
                fact: {
                  id: fact.id,
                  content: fact.content,
                  domain: fact.domain,
                  creator: fact.creator,
                  confidence: fact.validation_confidence,
                  queries: fact.query_count,
                  stake: fact.stake_amount,
                  validations: fact.validations || [],
                  refutations: fact.refutations || [],
                  earnings: fact.total_earnings || 0,
                  cryptographicProof: fact.proof_hash,
                },
              }, null, 2),
            },
          ],
        };
      }

      case "validate_fact": {
        const { factId, action, stake = 30.0, evidence } = args as any;
        
        if (!QFOT_WALLET_ID) {
          throw new Error("QFOT_WALLET_ID not configured");
        }
        
        const result = await qfotAPICall(`/facts/${factId}/${action}`, "POST", {
          wallet_id: QFOT_WALLET_ID,
          alias: QFOT_ALIAS,
          stake,
          evidence,
        });
        
        return {
          content: [
            {
              type: "text",
              text: JSON.stringify({
                success: true,
                action,
                factId,
                transactionId: result.transaction_id,
                newConfidence: result.new_confidence,
                reward: action === "validate" ? `Potential ${stake * 0.05} QFOT if consensus` : `Potential ${stake * 1.5} QFOT if refutation succeeds`,
              }, null, 2),
            },
          ],
        };
      }

      case "submit_fact": {
        const { content, domain, stake = 30.0 } = args as any;
        
        const result = await qfotAPICall("/facts/submit", "POST", {
          content,
          domain,
          creator: QFOT_ALIAS,
          stake,
        });
        
        return {
          content: [
            {
              type: "text",
              text: JSON.stringify({
                success: true,
                factId: result.fact_id || result.id,
                message: "Fact submitted successfully! You will earn 70% of all query fees.",
                earnings: {
                  perQuery: "$0.007 (70% of $0.01)",
                  projectedAnnual: "Depends on query volume",
                },
              }, null, 2),
            },
          ],
        };
      }

      case "get_tokenomics": {
        const { alias = QFOT_ALIAS } = args as any;
        
        // Query all facts by this creator
        const results = await qfotAPICall(`/facts/search?limit=5000`);
        const userFacts = results.results.filter((f: any) => 
          f.creator.includes(alias) || f.creator.startsWith("FoT")
        );
        
        const totalQueries = userFacts.reduce((sum: number, f: any) => sum + (f.query_count || 0), 0);
        const lifetimeEarnings = totalQueries * 0.007; // 70% of $0.01
        
        return {
          content: [
            {
              type: "text",
              text: JSON.stringify({
                alias,
                portfolio: {
                  factsOwned: userFacts.length,
                  totalQueries,
                  lifetimeEarnings: lifetimeEarnings.toFixed(2),
                  averageConfidence: (userFacts.reduce((sum: number, f: any) => sum + (f.validation_confidence || 0), 0) / userFacts.length).toFixed(2),
                },
                projections: {
                  dailyEstimate: (lifetimeEarnings / 30).toFixed(2),
                  monthlyEstimate: (lifetimeEarnings).toFixed(2),
                  annualEstimate: (lifetimeEarnings * 12).toFixed(2),
                },
                topFacts: userFacts
                  .sort((a: any, b: any) => (b.query_count || 0) - (a.query_count || 0))
                  .slice(0, 5)
                  .map((f: any) => ({
                    id: f.id,
                    content: f.content.substring(0, 80) + "...",
                    queries: f.query_count,
                    earnings: (f.query_count * 0.007).toFixed(2),
                  })),
              }, null, 2),
            },
          ],
        };
      }

      case "get_network_stats": {
        const results = await qfotAPICall("/facts/search?limit=5000");
        const facts = results.results || [];
        
        const domains = facts.reduce((acc: any, f: any) => {
          acc[f.domain] = (acc[f.domain] || 0) + 1;
          return acc;
        }, {});
        
        const totalQueries = facts.reduce((sum: number, f: any) => sum + (f.query_count || 0), 0);
        const totalFees = totalQueries * 0.01;
        
        return {
          content: [
            {
              type: "text",
              text: JSON.stringify({
                network: {
                  totalFacts: facts.length,
                  domainDistribution: domains,
                  totalQueries,
                  totalFeesGenerated: totalFees.toFixed(2),
                  creatorEarnings: (totalFees * 0.70).toFixed(2),
                  platformEarnings: (totalFees * 0.15).toFixed(2),
                  governancePool: (totalFees * 0.10).toFixed(2),
                  ethicsPool: (totalFees * 0.05).toFixed(2),
                },
              }, null, 2),
            },
          ],
        };
      }

      case "get_top_facts": {
        const { sortBy = "queries", domain = "all", limit = 10 } = args as any;
        
        const results = await qfotAPICall("/facts/search?limit=5000");
        let facts = results.results || [];
        
        // Filter by domain
        if (domain !== "all") {
          facts = facts.filter((f: any) => f.domain === domain);
        }
        
        // Sort
        if (sortBy === "queries") {
          facts.sort((a: any, b: any) => (b.query_count || 0) - (a.query_count || 0));
        } else if (sortBy === "earnings") {
          facts.sort((a: any, b: any) => 
            ((b.query_count || 0) * 0.007) - ((a.query_count || 0) * 0.007)
          );
        } else if (sortBy === "recent") {
          facts.sort((a: any, b: any) => 
            new Date(b.created_at).getTime() - new Date(a.created_at).getTime()
          );
        }
        
        facts = facts.slice(0, limit);
        
        return {
          content: [
            {
              type: "text",
              text: JSON.stringify({
                sortBy,
                domain,
                topFacts: facts.map((f: any, index: number) => ({
                  rank: index + 1,
                  id: f.id,
                  content: f.content.substring(0, 100) + "...",
                  domain: f.domain,
                  creator: f.creator,
                  queries: f.query_count || 0,
                  earnings: ((f.query_count || 0) * 0.007).toFixed(2),
                  confidence: f.validation_confidence || 0,
                })),
              }, null, 2),
            },
          ],
        };
      }

      default:
        throw new Error(`Unknown tool: ${name}`);
    }
  } catch (error: any) {
    return {
      content: [
        {
          type: "text",
          text: `Error: ${error.message}`,
        },
      ],
      isError: true,
    };
  }
});

// Start server
async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);
  console.error("QFOT MCP Server running on stdio");
}

main().catch((error) => {
  console.error("Fatal error:", error);
  process.exit(1);
});

