// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

interface IERC20Token {
  function transfer(address, uint256) external returns (bool);
  function approve(address, uint256) external returns (bool);
  function transferFrom(address, address, uint256) external returns (bool);
  function totalSupply() external view returns (uint256);
  function balanceOf(address) external view returns (uint256);
  function allowance(address, address) external view returns (uint256);

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
}


contract FundRaising {

    uint internal imageCount = 0;
    address internal cUsdTokenAddress = 0x874069Fa1Eb16D44d622F2e0Ca25eeA172369bC1;
    using Safemath for uint;
    
    struct Campaign {
        address payable fundraiser;
        string title;
        string[5] images;
        string[2] tags;
        string description;
        uint supporters;
        uint raised;
        uint goal;
        uint256 end_time;
        bool active;
    }

    mapping (uint => Campaign) internal campaigns;

    uint totalCampaigns = 0;
    
    address owner;

    modifier isOwnerOrActive(uint _index){

    require(campaigns[_index].active || msg.sender == owner, "campaign is inactive");

        _;
    }

      modifier isActive(uint _index){

     require(msg.sender == owner, 'only owner can modify campaign');
        _;
    }


    constructor() {
        owner = msg.sender;
    }

    function startCampaign(
        string memory _title,
        string[5] memory _images,
        string[2] memory _tags,
        string memory _description,
        uint _goal,
        uint _end_time
    ) public {
        campaigns[totalCampaigns] = Campaign(
            payable(msg.sender),
            _title,
            _images,
            _tags,
            _description,
            0, // supporters is 0
            0, // amount raised is 0
            _goal,
            _end_time,
            true // automatic activation status set to True
        );
        totalCampaigns.add(1);
    }

    function fetchCampaign(uint _index) isOwnerOrActive(_index) public view returns (
        address payable,
        string memory,
        string[5] memory,
        string[2] memory,
        string memory
    ) {

       
        return (
            campaigns[_index].fundraiser,
            campaigns[_index].title, 
            campaigns[_index].images,
            campaigns[_index].tags,
            campaigns[_index].description
        );
    }

     function fetchCampaignMeta(uint _index)  isOwnerOrActive(_index) public view returns (
        uint,
        uint,
        uint,
        uint256,
        bool
    ) {

        return (
            campaigns[_index].supporters,
            campaigns[_index].goal,
            campaigns[_index].raised,
            campaigns[_index].end_time,
            campaigns[_index].active
        );
    }
    
    function supportCampaign(uint _index, uint _amount) public payable  {

        require(campaigns[_index].active, "you can not support an inactive campaign");

        require(
            IERC20Token(cUsdTokenAddress).transferFrom(
            msg.sender,
            campaigns[_index].fundraiser,
            _amount), "Transfer failed."
        );

        campaigns[_index].supporters.add(1);

        campaigns[_index].raised.add(_amount);
    }
    
    function getTotalCampaign() public view returns (uint) {
        return (totalCampaigns);
    }

    function deactivateCampaign(uint _index) public {

        require(campaigns[_index].fundraiser == payable(msg.sender) || msg.sender == payable(msg.sender), 'only fundraiser or owner can modify campaign');

        campaigns[_index].active = false; 

    }

    function activateCampaign(uint _index) isActive(_index) public {
        campaigns[_index].active = true; 

    }

}
