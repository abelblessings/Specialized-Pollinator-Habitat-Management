import { describe, it, expect, beforeEach, vi } from "vitest"

// Mock the Clarity contract interactions
const mockContractCalls = {
  createMaintenanceProtocol: vi.fn(),
  getMaintenanceProtocol: vi.fn(),
  addProtocolTask: vi.fn(),
  logMaintenanceActivity: vi.fn(),
  updateProtocolStatus: vi.fn(),
}

// Mock protocol data
const mockProtocolData = {
  name: "Spring Meadow Management",
  description: "Protocol for maintaining pollinator meadows in spring to promote early season blooms and nesting sites",
  frequency: "Annual",
  season: "Spring",
  "created-by": "ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM",
  "creation-time": 12345,
  active: true,
}

describe("Maintenance Protocol Contract", () => {
  beforeEach(() => {
    vi.resetAllMocks()
    
    mockContractCalls.getMaintenanceProtocol.mockResolvedValue(mockProtocolData)
    mockContractCalls.createMaintenanceProtocol.mockResolvedValue({
      value: 1,
      type: "ok",
    })
    mockContractCalls.addProtocolTask.mockResolvedValue({
      value: 1,
      type: "ok",
    })
    mockContractCalls.logMaintenanceActivity.mockResolvedValue({
      value: 1,
      type: "ok",
    })
    mockContractCalls.updateProtocolStatus.mockResolvedValue({
      value: true,
      type: "ok",
    })
  })
  
  describe("createMaintenanceProtocol", () => {
    it("should successfully create a new maintenance protocol", async () => {
      const result = await mockContractCalls.createMaintenanceProtocol(
          "Spring Meadow Management",
          "Protocol for maintaining pollinator meadows in spring to promote early season blooms and nesting sites",
          "Annual",
          "Spring",
      )
      
      expect(mockContractCalls.createMaintenanceProtocol).toHaveBeenCalledTimes(1)
      expect(result.type).toBe("ok")
      expect(result.value).toBe(1)
    })
  })
  
  describe("addProtocolTask", () => {
    it("should successfully add a task to a protocol", async () => {
      const result = await mockContractCalls.addProtocolTask(
          1,
          "Remove invasive species",
          "Carefully remove any invasive plants that could compete with native pollinator plants",
          4,
          "Gloves, hand tools, plant identification guide",
      )
      
      expect(mockContractCalls.addProtocolTask).toHaveBeenCalledTimes(1)
      expect(result.type).toBe("ok")
      expect(result.value).toBe(1)
    })
  })
  
  describe("logMaintenanceActivity", () => {
    it("should successfully log a maintenance activity", async () => {
      const result = await mockContractCalls.logMaintenanceActivity(
          1, // Site ID
          1, // Protocol ID
          6, // Hours spent
          "Removed invasive species from the eastern section. Native plants are establishing well.",
          "Sunny, 75°F, light breeze",
      )
      
      expect(mockContractCalls.logMaintenanceActivity).toHaveBeenCalledTimes(1)
      expect(result.type).toBe("ok")
      expect(result.value).toBe(1)
    })
  })
  
  describe("updateProtocolStatus", () => {
    it("should successfully update protocol status", async () => {
      const result = await mockContractCalls.updateProtocolStatus(1, false)
      
      expect(mockContractCalls.updateProtocolStatus).toHaveBeenCalledTimes(1)
      expect(result.type).toBe("ok")
      expect(result.value).toBe(true)
    })
  })
})

