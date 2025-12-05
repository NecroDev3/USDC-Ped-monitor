import assert from "assert";
import { 
  TestHelpers,
  PegMonitor_OwnershipTransferred
} from "generated";
const { MockDb, PegMonitor } = TestHelpers;

describe("PegMonitor contract OwnershipTransferred event tests", () => {
  // Create mock db
  const mockDb = MockDb.createMockDb();

  // Creating mock for PegMonitor contract OwnershipTransferred event
  const event = PegMonitor.OwnershipTransferred.createMockEvent({/* It mocks event fields with default values. You can overwrite them if you need */});

  it("PegMonitor_OwnershipTransferred is created correctly", async () => {
    // Processing the event
    const mockDbUpdated = await PegMonitor.OwnershipTransferred.processEvent({
      event,
      mockDb,
    });

    // Getting the actual entity from the mock database
    let actualPegMonitorOwnershipTransferred = mockDbUpdated.entities.PegMonitor_OwnershipTransferred.get(
      `${event.chainId}_${event.block.number}_${event.logIndex}`
    );

    // Creating the expected entity
    const expectedPegMonitorOwnershipTransferred: PegMonitor_OwnershipTransferred = {
      id: `${event.chainId}_${event.block.number}_${event.logIndex}`,
      previousOwner: event.params.previousOwner,
      newOwner: event.params.newOwner,
    };
    // Asserting that the entity in the mock database is the same as the expected entity
    assert.deepEqual(actualPegMonitorOwnershipTransferred, expectedPegMonitorOwnershipTransferred, "Actual PegMonitorOwnershipTransferred should be the same as the expectedPegMonitorOwnershipTransferred");
  });
});
