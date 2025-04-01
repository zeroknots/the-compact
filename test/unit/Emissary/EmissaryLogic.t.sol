import { Test, console } from "forge-std/Test.sol";
import { ResetPeriod } from "src/types/ResetPeriod.sol";
import "./MockEmissaryLogic.sol";
import "src/test/AlwaysOKEmissary.sol";
import "src/test/AlwaysOKAllocator.sol";

contract EmissaryLogicTest is Test {
    MockEmissaryLogic logic;

    AlwaysOKEmissary emissary1;
    AlwaysOKEmissary emissary2;

    address sponsor;
    AlwaysOKAllocator allocator;

    function setUp() public {
        logic = new MockEmissaryLogic();

        sponsor = makeAddr("sponsor");
        emissary1 = new AlwaysOKEmissary();
        emissary2 = new AlwaysOKEmissary();
        allocator = new AlwaysOKAllocator();

        logic.registerAllocator(address(allocator), "");

        vm.warp(1743479729);
    }

    function test_new_emissary() public {
        bool success = logic.assignEmissary(sponsor, address(allocator), address(emissary1), "", ResetPeriod.TenMinutes);
        assertTrue(success);

        (EmissaryStatus status, uint256 assignableAt, address currentEmissary) = logic.getEmissaryStatus(sponsor, address(allocator));

        assertTrue(status == EmissaryStatus.Enabled, "Status");
        assertTrue(assignableAt == type(uint48).max, "timestamp");
        assertTrue(currentEmissary == address(emissary1), "addr");
    }

    function test_new_emissary_withoutSchedule() public {
        test_new_emissary();
        vm.expectRevert();
        bool success = logic.assignEmissary(sponsor, address(allocator), address(emissary1), "", ResetPeriod.TenMinutes);
    }

    function test_reset_emissary() public {
        (EmissaryStatus status, uint256 assignableAt, address currentEmissary) = logic.getEmissaryStatus(sponsor, address(allocator));

        assertTrue(status == EmissaryStatus.Disabled, "Status");
        assertTrue(assignableAt == 0, "timestamp");
        assertTrue(currentEmissary == address(0), "addr");

        test_new_emissary();
        logic.scheduleEmissaryAssignment(sponsor, address(allocator));
        (status, assignableAt, currentEmissary) = logic.getEmissaryStatus(sponsor, address(allocator));

        assertTrue(status == EmissaryStatus.Scheduled, "Status");
        assertTrue(assignableAt == block.timestamp + 10 minutes, "timestamp");
        assertTrue(currentEmissary == address(emissary1), "addr");

        vm.warp(block.timestamp + 1 minutes);

        vm.expectRevert();
        bool success = logic.assignEmissary(sponsor, address(allocator), address(emissary1), "", ResetPeriod.TenMinutes);
        vm.warp(block.timestamp + 10 minutes);
        success = logic.assignEmissary(sponsor, address(allocator), address(emissary2), "", ResetPeriod.TenMinutes);

        (status, assignableAt, currentEmissary) = logic.getEmissaryStatus(sponsor, address(allocator));

        assertTrue(status == EmissaryStatus.Enabled, "Status");
        assertTrue(assignableAt == type(uint48).max, "timestamp");
        assertTrue(currentEmissary == address(emissary2), "addr");
    }

    function test_disable_emissary() public {
        (EmissaryStatus status, uint256 assignableAt, address currentEmissary) = logic.getEmissaryStatus(sponsor, address(allocator));

        assertTrue(status == EmissaryStatus.Disabled, "Status should be disabled");
        assertTrue(assignableAt == 0, "timestamp");
        assertTrue(currentEmissary == address(0), "addr");

        // now we set the emissary
        test_new_emissary();

        logic.scheduleEmissaryAssignment(sponsor, address(allocator));
        (status, assignableAt, currentEmissary) = logic.getEmissaryStatus(sponsor, address(allocator));

        assertTrue(status == EmissaryStatus.Scheduled, "Status should be scheduled");
        assertTrue(assignableAt == block.timestamp + 10 minutes, "timestamp");
        assertTrue(currentEmissary == address(emissary1), "addr");

        vm.warp(block.timestamp + 10 minutes);
        bool success = logic.assignEmissary(sponsor, address(allocator), address(0), "", ResetPeriod.TenMinutes);

        (status, assignableAt, currentEmissary) = logic.getEmissaryStatus(sponsor, address(allocator));

        assertTrue(status == EmissaryStatus.Disabled, "Status");
        assertTrue(assignableAt == 0, "timestamp should be 0");
        assertTrue(currentEmissary == address(0), "addr");
    }
}
