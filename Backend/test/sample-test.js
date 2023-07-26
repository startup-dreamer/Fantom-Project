const { expect } = require("chai");

describe("NFTFractionalize", function () {
  let fractionalize;
  let erc721Mock;
  let erc20Mock;
  let tokenId =1;
  let owner;
  let user1;

  beforeEach(async function () {
    [owner, user1] = await ethers.getSigners();

    const NFTFractionalize = await ethers.getContractFactory("NFTFractionalize");
    const ERC721Mock = await ethers.getContractFactory("MockNFT");

    erc721Mock = await ERC721Mock.deploy();
    fractionalize = await NFTFractionalize.deploy();
    await erc721Mock.mint(owner.address, tokenId);
  });

  // it("should transfer NFT and mint ERC20 tokens", async function () {
  //   const tokenId = 1;
  //   const amount = 100;

  //   await erc721Mock.mint(owner.address, tokenId);
  //   await erc721Mock.approve(fractionalize.address, tokenId);

  //   const name = await erc721Mock.name();
  //   const symbol = await erc721Mock.symbol();

  //   await expect(
  //     fractionalize.transferNFT(name, symbol, erc721Mock.address, tokenId, amount)
  //   )
  //     .to.emit(erc721Mock, "Transfer")
  //     .withArgs(owner.address, fractionalize.address, tokenId);

  //   const erc20ContractAddress = await fractionalize.fractionalData(
  //     erc721Mock.address
  //   );
  //   const erc20Contract = await ethers.getContractAt(
  //     "ERC20Modified",
  //     erc20ContractAddress.erc20Contract
  //   );

  //   expect(await erc20Contract.balanceOf(owner.address)).to.equal(amount);
  // });

  it("should put NFT fraction for sale", async function () {
    const price = ethers.utils.parseEther("1.0");

    await fractionalize.putForSale(erc721Mock.address, price);

    expect(await fractionalize.isForSale()).to.be.true;
    expect(await fractionalize.salePrice()).to.equal(price);
  });

  // it("should purchase NFT fraction", async function () {
  //   const tokenId = 1;
  //   const amount = 100;
  //   const price = ethers.utils.parseEther("1.0");

  //   await erc721Mock.mint(owner.address, tokenId);
  //   await erc721Mock.approve(fractionalize.address, tokenId);

  //   await fractionalize.transferNFT(erc721Mock.address, tokenId, amount);

  //   await fractionalize.putForSale(erc20Mock.address, price);

  //   const user1BalanceBefore = await ethers.provider.getBalance(user1.address);
  //   const ownerBalanceBefore = await ethers.provider.getBalance(owner.address);

  //   await expect(() =>
  //     fractionalize.connect(user1).purchase(erc20Mock.address, {
  //       value: price,
  //     })
  //   )
  //     .to.changeEtherBalances(
  //       [user1, owner],
  //       [ethers.BigNumber.from(price).neg(), price]
  //     )
  //     .to.emit(erc721Mock, "Transfer")
  //     .withArgs(fractionalize.address, user1.address, tokenId);

  //   const user1BalanceAfter = await ethers.provider.getBalance(user1.address);
  //   const ownerBalanceAfter = await ethers.provider.getBalance(owner.address);

  //   expect(user1BalanceAfter.sub(user1BalanceBefore)).to.equal(price);
  //   expect(ownerBalanceAfter.sub(ownerBalanceBefore)).to.equal(price);
  // });

  // it("should redeem ERC20 tokens for the sale price", async function () {
  //   const tokenId = 1;
  //   const amount = 100;
  //   const price = ethers.utils.parseEther("1.0");

  //   await erc721Mock.mint(owner.address, tokenId);
  //   await erc721Mock.approve(fractionalize.address, tokenId);

  //   await fractionalize.transferNFT(erc721Mock.address, tokenId, amount);

  //   await fractionalize.putForSale(erc20Mock.address, price);

  //   await fractionalize.connect(user1).purchase(erc20Mock.address, {
  //     value: price,
  //   });

  //   const user1BalanceBefore = await ethers.provider.getBalance(user1.address);

  //   await expect(
  //     fractionalize.connect(user1).redeemToken(erc20Mock.address, amount)
  //   )
  //     .to.changeEtherBalance(user1, price)
  //     .to.changeTokenBalance(erc20Mock, user1, price);

  //   const user1BalanceAfter = await ethers.provider.getBalance(user1.address);

  //   expect(user1BalanceAfter.sub(user1BalanceBefore)).to.equal(price);
  // });
});
