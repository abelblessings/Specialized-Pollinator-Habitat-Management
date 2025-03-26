import { describe, it, expect, beforeEach, vi } from "vitest"

// Mock the Clarity contract interactions
const mockContractCalls = {
  registerPollinatorSpecies: vi.fn(),
  getPollinatorSpecies: vi.fn(),
  createMonitoringSession: vi.fn(),
  recordPollinatorObservation: vi.fn(),
  createSiteAssessment: vi.fn(),
}

// Mock pollinator species data
const mockPollinatorSpeciesData = {
  "scientific-name": "Bombus impatiens",
  "common-name": "Common Eastern Bumble Bee",
  type: "Bee",
  "conservation-status": "Least Concern",
  "registered-by": "ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM",
  "registration-time": 12345,
}

describe("Impact Assessment Contract", () => {
  beforeEach(() => {
    vi.resetAllMocks()
    
    mockContractCalls.getPollinatorSpecies.mockResolvedValue(mockPollinatorSpeciesData)
    mockContractCalls.registerPollinatorSpecies.mockResolvedValue({
      value: 1,
      type: "ok",
    })
    mockContractCalls.createMonitoringSession.mockResolvedValue({
      value: 1,
      type: "ok",
    })
    mockContractCalls.recordPollinatorObservation.mockResolvedValue({
      value: 1,
      type: "ok",
    })
    mockContractCalls.createSiteAssessment.mockResolvedValue({
      value: 1,
      type: "ok",
    })
  })
  
  describe("registerPollinatorSpecies", () => {
    it("should successfully register a new pollinator species", async () => {
      const result = await mockContractCalls.registerPollinatorSpecies(
          "Bombus impatiens",
          "Common Eastern Bumble Bee",
          "Bee",
          "Least Concern",
      )
      
      expect(mockContractCalls.registerPollinatorSpecies).toHaveBeenCalledTimes(1)
      expect(result.type).toBe("ok")
      expect(result.value).toBe(1)
    })
  })
  
  describe("createMonitoringSession", () => {
    it("should successfully create a monitoring session", async () => {
      const result = await mockContractCalls.createMonitoringSession(
          1, // Site ID
          1000, // Start time (Unix timestamp)
          1200, // End time (Unix timestamp)
          25, // Temperature (Celsius)
          5, // Wind speed (km/h)
          30, // Cloud cover (percentage)
          "Good conditions for monitoring. Many pollinators active.",
      )
      
      expect(mockContractCalls.createMonitoringSession).toHaveBeenCalledTimes(1)
      expect(result.type).toBe("ok")
      expect(result.value).toBe(1)
    })
  })
  
  describe("recordPollinatorObservation", () => {
    it("should successfully record a pollinator observation", async () => {
      const result = await mockContractCalls.recordPollinatorObservation(
          1, // Session ID
          1, // Species ID
          12, // Count
          "Foraging",
          1, // Plant species ID
          "Actively collecting pollen from multiple flowers",
      )
      
      expect(mockContractCalls.recordPollinatorObservation).toHaveBeenCalledTimes(1)
      expect(result.type).toBe("ok")
      expect(result.value).toBe(1)
    })
  })
  
  describe("createSiteAssessment", () => {
    it("should successfully create a site assessment", async () => {
      const result = await mockContractCalls.createSiteAssessment(
          1, // Site ID
          8, // Pollinator diversity score (0-10)
          9, // Pollinator abundance score (0-10)
          7, // Habitat quality score (0-10)
          "Site shows excellent pollinator activity. Recommend increasing early spring blooming plants to support early emerging bees.",
      )
      
      expect(mockContractCalls.createSiteAssessment).toHaveBeenCalledTimes(1)
      expect(result.type).toBe("ok")
      expect(result.value).toBe(1)
    })
  })
})

