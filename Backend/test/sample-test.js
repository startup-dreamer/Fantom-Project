const { expect } = require("chai");


describe("Fractional_NFT", function () {
  let fractionalNFT;
  let owner;
  let buyer;

  const name = "Fractional NFT";
  const symbol = "F-NFT";
  const salePrice = ethers.utils.parseEther("1");
  const initialSupply = ethers.utils.parseEther("100");
  const tokenId = 1;
  let nftContract;

  beforeEach(async function () {
    [owner, buyer] = await ethers.getSigners();
  
    const NFTContract = await ethers.getContractFactory("MockNFT");
    nftContract = await NFTContract.deploy();
    await nftContract.deployed();
  
    const FractionalNFT = await ethers.getContractFactory("Fractional_NFT");
    fractionalNFT = await FractionalNFT.deploy(name, symbol, nftContract.address);
    await fractionalNFT.deployed();
  });
  

  it("should mint the NFT", async function () {
    await nftContract.connect(owner).mint(owner.address, tokenId);
    const Owner = await nftContract.ownerOf(tokenId);
    // console.log(owner.address, Owner);
    expect(owner.address).to.equal(Owner);
  })

  it("should approve the fraction contract", async function () {
    await nftContract.connect(owner).setApprovalForAll(fractionalNFT.address, true);
    const isApproved = await nftContract.connect(owner).isApprovedForAll(owner.address, fractionalNFT.address);
    expect(isApproved).to.equal(true);
  })

  it("should transfer NFT and mint tokens", async function () {
    const tx = await fractionalNFT.connect(owner).transferNFT(tokenId, initialSupply);
    const balance = await fractionalNFT.balanceOf(owner.address);
    // console.log(tx);    
    expect(balance).to.equal(initialSupply);
  });

  it("should put NFT for sale", async function () {
    await fractionalNFT.connect(owner).putForSale(salePrice);
    const isForSale = await fractionalNFT.forSale();
    expect(isForSale).to.equal(true);
  });

  it("should allow purchase of the NFT", async function () {
    await fractionalNFT.connect(owner).putForSale(salePrice);
    await expect(fractionalNFT.connect(buyer).purchase({ value: salePrice }))
      .to.emit(fractionalNFT, "Transfer")
      .withArgs(owner.address, buyer.address, tokenId);
  });

  it("should allow redemption of tokens", async function () {
    await fractionalNFT.connect(owner).putForSale(salePrice);
    await fractionalNFT.connect(buyer).purchase({ value: salePrice });

    const buyerBalanceBefore = await ethers.provider.getBalance(buyer.address);
    const tokenBalanceBefore = await fractionalNFT.balanceOf(buyer.address);

    await expect(fractionalNFT.connect(buyer).redeemToken(tokenBalanceBefore))
      .to.changeEtherBalance(buyer, salePrice);

    const buyerBalanceAfter = await ethers.provider.getBalance(buyer.address);
    expect(buyerBalanceAfter.sub(buyerBalanceBefore)).to.equal(salePrice);
  });
});
