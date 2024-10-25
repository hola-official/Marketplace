import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const MarketplaceModule = buildModule("MarketplaceModule", (m) => {

  const Marketplace = m.contract("Marketplace");

  return { Marketplace };
});

export default MarketplaceModule;
