import { describe, it, expect, beforeEach, vi } from "vitest"

// Mock the Clarity contract interactions
const mockContractCalls = {
  registerPlantSpecies: vi.fn(),
  getPlantSpecies: vi.fn(),
  addPollinatorSupport: vi.fn(),
  recordSitePlanting: vi.fn(),
  updatePlantingStatus: vi.fn(),
}

// Mock plant species data
const mockPlantSpeciesData = {
  "scientific-name": "Asclepias tuberosa",
  "common-name": "Butterfly Weed",
  "plant-type": "Perennial",
  "bloom-season": "Summer",
  "registered-by": "ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM",
  "registration-time": 12345,
}

describe("Plant Inventory Contract", () => {
  beforeEach(() => {
    vi.resetAllMocks()
    
    mockContractCalls.getPlantSpecies.mockResolvedValue(mockPlantSpeciesData)
    mockContractCalls.registerPlantSpecies.mockResolvedValue({
      value: 1,
      type: "ok",
    })
    mockContractCalls.addPollinatorSupport.mockResolvedValue({
      value: true,
      type: "ok",
    })
    mockContractCalls.recordSitePlanting.mockResolvedValue({
      value: 1,
      type: "ok",
    })
    mockContractCalls.updatePlantingStatus.mockResolvedValue({
      value: true,
      type: "ok",
    })
  })
  
  describe("registerPlantSpecies", () => {
    it("should successfully register a new pollinator-friendly plant species", async () => {
      const result = await mockContractCalls.registerPlantSpecies(
          "Asclepias tuberosa",
          "Butterfly Weed",
          "Perennial",
          "Summer",
      )
      
      expect(mockContractCalls.registerPlantSpecies).toHaveBeenCalledTimes(1)
      expect(result.type).toBe("ok")
      expect(result.value).toBe(1)
    })
  })
  
  describe("addPollinatorSupport", () => {
    it("should successfully add pollinator support data to a plant species", async () => {
      const result = await mockContractCalls.addPollinatorSupport(
          1,
          9, // Nectar value (0-10)
          8, // Pollen value (0-10)
          "Monarch butterflies, bumblebees, honeybees, hummingbirds",
          60, // Bloom duration in days
      )
      
      expect(mockContractCalls.addPollinatorSupport).toHaveBeenCalledTimes(1)
      expect(result.type).toBe("ok")
      expect(result.value).toBe(true)
    })
  })
  
  describe("recordSitePlanting", () => {
    it("should successfully record a planting at a site", async () => {
      const result = await mockContractCalls.recordSitePlanting(
          1, // Site ID
          1, // Species ID
          50, // Quantity
          200, // Planting area in square meters
      )
      
      expect(mockContractCalls.recordSitePlanting).toHaveBeenCalledTimes(1)
      expect(result.type).toBe("ok")
      expect(result.value).toBe(1)
    })
  })
  
  describe("updatePlantingStatus", () => {
    it("should successfully update the status of a planting", async () => {
      const result = await mockContractCalls.updatePlantingStatus(
          1, // Site ID
          1, // Planting ID
          "THRIVING",
      )
      
      expect(mockContractCalls.updatePlantingStatus).toHaveBeenCalledTimes(1)
      expect(result.type).toBe("ok")
      expect(result.value).toBe(true)
    })
  })
})

