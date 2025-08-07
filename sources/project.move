module myaddr::TokenWithBurnTax {
    use aptos_framework::signer;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;
    use aptos_framework::event;
    struct BurnTaxToken has store, key {
        total_supply: u64,        
        burned_amount: u64,       
        burn_tax_rate: u64,       
        owner: address,           
    }
        struct TokenBurnEvent has drop, store {
        from_address: address,
        amount_burned: u64,
        remaining_supply: u64,
    }
        public fun initialize_token(
        owner: &signer, 
        initial_supply: u64, 
        burn_tax_rate: u64
    ) {
        let owner_addr = signer::address_of(owner);
        let token = BurnTaxToken {
            total_supply: initial_supply,
            burned_amount: 0,
            burn_tax_rate, 
            owner: owner_addr,
        };
        
        move_to(owner, token);
    }
    public fun transfer_with_burn(
        sender: &signer,
        token_owner: address,
        recipient: address,
        amount: u64
    ) acquires BurnTaxToken {
        let token = borrow_global_mut<BurnTaxToken>(token_owner);
        let burn_amount = (amount * token.burn_tax_rate) / 10000;
        let transfer_amount = amount - burn_amount;
        token.total_supply = token.total_supply - burn_amount;
        token.burned_amount = token.burned_amount + burn_amount;
        let coins_to_transfer = coin::withdraw<AptosCoin>(sender, transfer_amount);
        coin::deposit<AptosCoin>(recipient, coins_to_transfer);

    }

}
