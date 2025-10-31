#!/usr/bin/env node
/**
 * UNIFIED QFOT MCP SERVER - Complete Domain Integration
 * 
 * Provides AI agents with native access to:
 * - Live Medical Research (PubMed, FDA, clinical dosing)
 * - Live Legal Research (Case law, statutes, regulations)
 * - Live Education Research (ERIC, Common Core, best practices)
 * - Blockchain knowledge graph
 * - Provenance tracking
 * - Clinical decision support
 * 
 * ALL with full MCP protocol support for AI agents (Claude, Cursor, etc.)
 */

import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
} from "@modelcontextprotocol/sdk/types.js";
import axios from "axios";
import { spawn } from "child_process";
import * as path from "path";

const QFOT_API_URL = process.env.QFOT_API_URL || "http://94.130.97.66/api";
const BLOCKCHAIN_DIR = path.resolve(__dirname, "..");

interface PatientVitals {
  weight_kg: number;
  height_cm: number;
  age: number;
  sex: string;
  serum_creatinine_mg_dl?: number;
  bilirubin_mg_dl?: number;
  albumin_g_dl?: number;
}

class UnifiedQFOTMCPServer {
  private server: Server;

  constructor() {
    this.server = new Server(
      {
        name: "qfot-unified",
        version: "2.0.0",
      },
      {
        capabilities: {
          tools: {},
        },
      }
    );

    this.setupToolHandlers();
    this.setupErrorHandling();
  }

  private setupToolHandlers() {
    // List all available tools
    this.server.setRequestHandler(ListToolsRequestSchema, async () => ({
      tools: [
        // === MEDICAL TOOLS ===
        {
          name: "fetch_latest_medical_research",
          description: "Fetch latest medical research from PubMed with full provenance (DOI, authors, citations, blockchain links)",
          inputSchema: {
            type: "object",
            properties: {
              query: {
                type: "string",
                description: "Medical topic to search (e.g., 'CRISPR gene therapy', 'COVID-19 treatment')",
              },
              days_back: {
                type: "number",
                description: "How many days back to search (default: 30)",
                default: 30,
              },
            },
            required: ["query"],
          },
        },
        {
          name: "calculate_drug_dosing",
          description: "Calculate evidence-based drug dosing based on patient vitals (weight, age, renal/hepatic function) with full provenance and blockchain validation",
          inputSchema: {
            type: "object",
            properties: {
              drug_name: {
                type: "string",
                description: "Drug name (e.g., 'vancomycin', 'enoxaparin', 'digoxin')",
              },
              patient: {
                type: "object",
                description: "Patient vitals and demographics",
                properties: {
                  weight_kg: { type: "number" },
                  height_cm: { type: "number" },
                  age: { type: "number" },
                  sex: { type: "string", enum: ["M", "F"] },
                  serum_creatinine_mg_dl: { type: "number" },
                  bilirubin_mg_dl: { type: "number" },
                  albumin_g_dl: { type: "number" },
                },
                required: ["weight_kg", "height_cm", "age", "sex"],
              },
            },
            required: ["drug_name", "patient"],
          },
        },
        {
          name: "check_drug_interactions",
          description: "Check for drug-drug interactions with severity, effects, management, and provenance",
          inputSchema: {
            type: "object",
            properties: {
              drugs: {
                type: "array",
                items: { type: "string" },
                description: "List of drug names to check for interactions",
              },
            },
            required: ["drugs"],
          },
        },
        {
          name: "fetch_fda_safety_alerts",
          description: "Fetch latest FDA drug safety alerts with full provenance",
          inputSchema: {
            type: "object",
            properties: {
              days_back: {
                type: "number",
                description: "How many days back to search (default: 90)",
                default: 90,
              },
            },
          },
        },
        
        // === LEGAL TOOLS ===
        {
          name: "fetch_recent_case_law",
          description: "Fetch recent Supreme Court and federal case law with Bluebook citations and blockchain validation",
          inputSchema: {
            type: "object",
            properties: {
              court: {
                type: "string",
                description: "Court to search (e.g., 'scotus', 'ca9', 'nysd')",
                default: "scotus",
              },
              days_back: {
                type: "number",
                description: "How many days back to search (default: 365)",
                default: 365,
              },
            },
          },
        },
        {
          name: "fetch_federal_legislation",
          description: "Fetch recent federal legislation with Public Law citations and provenance",
          inputSchema: {
            type: "object",
            properties: {
              days_back: {
                type: "number",
                description: "How many days back to search (default: 730)",
                default: 730,
              },
            },
          },
        },
        {
          name: "fetch_state_law_updates",
          description: "Fetch recent state law updates with full citations and jurisdictional analysis",
          inputSchema: {
            type: "object",
            properties: {
              state: {
                type: "string",
                description: "State name (e.g., 'California', 'New York', 'Texas')",
              },
            },
            required: ["state"],
          },
        },
        
        // === EDUCATION TOOLS ===
        {
          name: "fetch_education_research",
          description: "Fetch latest educational research from ERIC with APA citations and evidence levels",
          inputSchema: {
            type: "object",
            properties: {
              topic: {
                type: "string",
                description: "Educational topic (e.g., 'metacognition', 'growth mindset', 'spaced practice')",
              },
              education_level: {
                type: "string",
                description: "Education level (e.g., 'K-5', '6-8', '9-12', 'higher_ed')",
              },
            },
            required: ["topic"],
          },
        },
        {
          name: "fetch_common_core_standards",
          description: "Fetch Common Core State Standards with full citations and implementation guidance",
          inputSchema: {
            type: "object",
            properties: {
              grade: {
                type: "string",
                description: "Grade level (e.g., '5', '8', '11')",
              },
              subject: {
                type: "string",
                description: "Subject area (e.g., 'Mathematics', 'English Language Arts')",
              },
            },
          },
        },
        {
          name: "fetch_pedagogical_best_practices",
          description: "Fetch evidence-based pedagogical best practices with meta-analysis results and implementation guidance",
          inputSchema: {
            type: "object",
            properties: {
              subject: {
                type: "string",
                description: "Subject area (optional filter)",
              },
            },
          },
        },
        
        // === BLOCKCHAIN TOOLS ===
        {
          name: "search_knowledge_graph",
          description: "Search QFOT knowledge graph with semantic search and provenance",
          inputSchema: {
            type: "object",
            properties: {
              query: {
                type: "string",
                description: "Search query",
              },
              domain: {
                type: "string",
                description: "Domain filter (medical, legal, education, scientific)",
              },
            },
            required: ["query"],
          },
        },
        {
          name: "get_fact_provenance",
          description: "Get full provenance for a specific fact (authors, citations, DOI, blockchain link)",
          inputSchema: {
            type: "object",
            properties: {
              fact_id: {
                type: "string",
                description: "Fact ID or blockchain link",
              },
            },
            required: ["fact_id"],
          },
        },
        {
          name: "validate_fact",
          description: "Validate a fact on the blockchain (requires QFOT stake)",
          inputSchema: {
            type: "object",
            properties: {
              fact_id: {
                type: "string",
                description: "Fact ID to validate",
              },
              validator_alias: {
                type: "string",
                description: "Validator alias (e.g., '@MedicalExpert')",
              },
              stake_amount: {
                type: "number",
                description: "QFOT stake amount (default: 25)",
                default: 25,
              },
            },
            required: ["fact_id", "validator_alias"],
          },
        },
      ],
    }));

    // Handle tool calls
    this.server.setRequestHandler(CallToolRequestSchema, async (request) => {
      const { name, arguments: args } = request.params;

      try {
        switch (name) {
          // Medical Tools
          case "fetch_latest_medical_research":
            return await this.fetchMedicalResearch(args);
          
          case "calculate_drug_dosing":
            return await this.calculateDrugDosing(args);
          
          case "check_drug_interactions":
            return await this.checkDrugInteractions(args);
          
          case "fetch_fda_safety_alerts":
            return await this.fetchFDASafetyAlerts(args);
          
          // Legal Tools
          case "fetch_recent_case_law":
            return await this.fetchRecentCaseLaw(args);
          
          case "fetch_federal_legislation":
            return await this.fetchFederalLegislation(args);
          
          case "fetch_state_law_updates":
            return await this.fetchStateLawUpdates(args);
          
          // Education Tools
          case "fetch_education_research":
            return await this.fetchEducationResearch(args);
          
          case "fetch_common_core_standards":
            return await this.fetchCommonCoreStandards(args);
          
          case "fetch_pedagogical_best_practices":
            return await this.fetchPedagogicalBestPractices(args);
          
          // Blockchain Tools
          case "search_knowledge_graph":
            return await this.searchKnowledgeGraph(args);
          
          case "get_fact_provenance":
            return await this.getFactProvenance(args);
          
          case "validate_fact":
            return await this.validateFact(args);
          
          default:
            throw new Error(`Unknown tool: ${name}`);
        }
      } catch (error) {
        return {
          content: [
            {
              type: "text",
              text: `Error executing ${name}: ${error instanceof Error ? error.message : String(error)}`,
            },
          ],
        };
      }
    });
  }

  // === MEDICAL TOOL IMPLEMENTATIONS ===

  private async fetchMedicalResearch(args: any) {
    const script = path.join(BLOCKCHAIN_DIR, "live_research_miner.py");
    const output = await this.runPythonScript(script, [
      "--query", args.query,
      "--days-back", String(args.days_back || 30),
      "--domain", "medical"
    ]);
    
    return {
      content: [
        {
          type: "text",
          text: `Latest Medical Research: ${args.query}\n\n${output}\n\nAll results include full provenance (DOI, PubMed ID, authors, citations) and blockchain validation links.`,
        },
      ],
    };
  }

  private async calculateDrugDosing(args: any) {
    const script = path.join(BLOCKCHAIN_DIR, "clinical_dosing_calculator.py");
    const patientJSON = JSON.stringify(args.patient);
    const output = await this.runPythonScript(script, [
      "--drug", args.drug_name,
      "--patient", patientJSON
    ]);
    
    return {
      content: [
        {
          type: "text",
          text: `Drug Dosing Calculation for ${args.drug_name}\n\n${output}\n\nIncludes: Dose adjustments, warnings, monitoring parameters, evidence-based guidelines (PMID), and blockchain validation link.`,
        },
      ],
    };
  }

  private async checkDrugInteractions(args: any) {
    const script = path.join(BLOCKCHAIN_DIR, "clinical_dosing_calculator.py");
    const output = await this.runPythonScript(script, [
      "--check-interactions",
      "--drugs", args.drugs.join(",")
    ]);
    
    return {
      content: [
        {
          type: "text",
          text: `Drug Interaction Analysis\n\n${output}\n\nIncludes: Severity level, mechanism, management recommendations, and provenance (PMID, guidelines).`,
        },
      ],
    };
  }

  private async fetchFDASafetyAlerts(args: any) {
    const script = path.join(BLOCKCHAIN_DIR, "live_research_miner.py");
    const output = await this.runPythonScript(script, [
      "--fda-alerts",
      "--days-back", String(args.days_back || 90)
    ]);
    
    return {
      content: [
        {
          type: "text",
          text: `FDA Safety Alerts (last ${args.days_back || 90} days)\n\n${output}\n\nAll alerts include: Drug name, adverse events, FDA report ID, and blockchain link.`,
        },
      ],
    };
  }

  // === LEGAL TOOL IMPLEMENTATIONS ===

  private async fetchRecentCaseLaw(args: any) {
    const script = path.join(BLOCKCHAIN_DIR, "legal_research_miner.py");
    const output = await this.runPythonScript(script, [
      "--court", args.court || "scotus",
      "--days-back", String(args.days_back || 365)
    ]);
    
    return {
      content: [
        {
          type: "text",
          text: `Recent Case Law\n\n${output}\n\nIncludes: Bluebook citations, court, judge, holding, precedential value, and blockchain validation links.`,
        },
      ],
    };
  }

  private async fetchFederalLegislation(args: any) {
    const script = path.join(BLOCKCHAIN_DIR, "legal_research_miner.py");
    const output = await this.runPythonScript(script, [
      "--legislation",
      "--days-back", String(args.days_back || 730)
    ]);
    
    return {
      content: [
        {
          type: "text",
          text: `Recent Federal Legislation\n\n${output}\n\nIncludes: Public Law citations, bill numbers, summaries, and blockchain links.`,
        },
      ],
    };
  }

  private async fetchStateLawUpdates(args: any) {
    const script = path.join(BLOCKCHAIN_DIR, "legal_research_miner.py");
    const output = await this.runPythonScript(script, [
      "--state-law",
      "--state", args.state
    ]);
    
    return {
      content: [
        {
          type: "text",
          text: `${args.state} Law Updates\n\n${output}\n\nIncludes: State code citations, effective dates, jurisdictional analysis, and blockchain links.`,
        },
      ],
    };
  }

  // === EDUCATION TOOL IMPLEMENTATIONS ===

  private async fetchEducationResearch(args: any) {
    const script = path.join(BLOCKCHAIN_DIR, "education_research_miner.py");
    const output = await this.runPythonScript(script, [
      "--topic", args.topic,
      ...(args.education_level ? ["--level", args.education_level] : [])
    ]);
    
    return {
      content: [
        {
          type: "text",
          text: `Education Research: ${args.topic}\n\n${output}\n\nIncludes: APA citations, ERIC IDs, evidence levels, effect sizes, and blockchain links.`,
        },
      ],
    };
  }

  private async fetchCommonCoreStandards(args: any) {
    const script = path.join(BLOCKCHAIN_DIR, "education_research_miner.py");
    const output = await this.runPythonScript(script, [
      "--common-core",
      ...(args.grade ? ["--grade", args.grade] : []),
      ...(args.subject ? ["--subject", args.subject] : [])
    ]);
    
    return {
      content: [
        {
          type: "text",
          text: `Common Core Standards\n\n${output}\n\nIncludes: Standard IDs, descriptions, grade levels, and blockchain validation links.`,
        },
      ],
    };
  }

  private async fetchPedagogicalBestPractices(args: any) {
    const script = path.join(BLOCKCHAIN_DIR, "education_research_miner.py");
    const output = await this.runPythonScript(script, [
      "--best-practices",
      ...(args.subject ? ["--subject", args.subject] : [])
    ]);
    
    return {
      content: [
        {
          type: "text",
          text: `Pedagogical Best Practices\n\n${output}\n\nIncludes: Evidence levels, effect sizes, implementation guidance, research citations, and blockchain links.`,
        },
      ],
    };
  }

  // === BLOCKCHAIN TOOL IMPLEMENTATIONS ===

  private async searchKnowledgeGraph(args: any) {
    const params = new URLSearchParams({
      q: args.query,
      ...(args.domain && { domain: args.domain }),
    });

    const response = await axios.get(`${QFOT_API_URL}/facts/search?${params}`);
    
    return {
      content: [
        {
          type: "text",
          text: JSON.stringify(response.data, null, 2),
        },
      ],
    };
  }

  private async getFactProvenance(args: any) {
    const response = await axios.get(`${QFOT_API_URL}/facts/${args.fact_id}/provenance`);
    
    const prov = response.data;
    const formatted = `
FACT PROVENANCE:
================

Fact ID: ${args.fact_id}
Domain: ${prov.domain}
Type: ${prov.node_type}

SOURCE:
  Authors: ${prov.authors?.join(", ") || "N/A"}
  Institution: ${prov.institution || "N/A"}
  Journal: ${prov.journal || "N/A"}
  Publication Date: ${prov.publication_date || "N/A"}
  DOI: ${prov.doi || "N/A"}
  PMID: ${prov.pmid || "N/A"}
  URL: ${prov.url || "N/A"}

CITATION:
  ${prov.citation || "N/A"}

BLOCKCHAIN:
  Link: ${prov.blockchain_link}
  Validated By: ${prov.validated_by?.join(", ") || "Pending"}
  Validation Stake: ${prov.validation_stake || 0} QFOT
  Query Count: ${prov.query_count || 0}
  Earnings: ${prov.qfot_earned || 0} QFOT

VERIFICATION:
  Verified: ${prov.verified ? "✅" : "⏳"}
  Last Updated: ${prov.last_updated}
`;
    
    return {
      content: [
        {
          type: "text",
          text: formatted,
        },
      ],
    };
  }

  private async validateFact(args: any) {
    const response = await axios.post(`${QFOT_API_URL}/facts/${args.fact_id}/validate`, {
      validator: args.validator_alias,
      stake: args.stake_amount || 25,
    });
    
    return {
      content: [
        {
          type: "text",
          text: `Fact validation submitted successfully.\n\nValidator: ${args.validator_alias}\nStake: ${args.stake_amount || 25} QFOT\nTransaction: ${response.data.transaction_id}`,
        },
      ],
    };
  }

  // === UTILITY METHODS ===

  private async runPythonScript(scriptPath: string, args: string[]): Promise<string> {
    return new Promise((resolve, reject) => {
      const python = spawn("python3", [scriptPath, ...args]);
      
      let stdout = "";
      let stderr = "";
      
      python.stdout.on("data", (data) => {
        stdout += data.toString();
      });
      
      python.stderr.on("data", (data) => {
        stderr += data.toString();
      });
      
      python.on("close", (code) => {
        if (code === 0) {
          resolve(stdout);
        } else {
          reject(new Error(`Script failed: ${stderr}`));
        }
      });
    });
  }

  private setupErrorHandling() {
    this.server.onerror = (error) => {
      console.error("[MCP Error]", error);
    };

    process.on("SIGINT", async () => {
      await this.server.close();
      process.exit(0);
    });
  }

  async run() {
    const transport = new StdioServerTransport();
    await this.server.connect(transport);
    console.error("Unified QFOT MCP Server running on stdio");
  }
}

const server = new UnifiedQFOTMCPServer();
server.run().catch(console.error);

