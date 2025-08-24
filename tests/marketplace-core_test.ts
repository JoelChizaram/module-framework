import { Clarinet, Tx, Chain, Account, types } from 'https://deno.land/x/clarinet@v1.0.5/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
    name: "Marketplace Core: Create Listing",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const deployer = accounts.get('deployer')!;
        const block = chain.mineBlock([
            Tx.contractCall('marketplace-core', 'create-listing', [
                types.ascii('Tech Gadget'),
                types.utf8('Advanced digital device'),
                types.uint(1000000),
                types.uint(10),
                types.ascii('electronics')
            ], deployer.address)
        ]);

        assertEquals(block.receipts.length, 1);
        block.receipts[0].result.expectOk().expectUint(1);
    }
});

Clarinet.test({
    name: "Marketplace Core: Get Listing",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const deployer = accounts.get('deployer')!;
        const block = chain.mineBlock([
            Tx.contractCall('marketplace-core', 'create-listing', [
                types.ascii('Book Collection'),
                types.utf8('Rare book set'),
                types.uint(500000),
                types.uint(5),
                types.ascii('books')
            ], deployer.address)
        ]);

        const listing = chain.callReadOnly('marketplace-core', 'get-listing', [types.uint(1)], deployer.address);
        listing.result.expectSome();
    }
});