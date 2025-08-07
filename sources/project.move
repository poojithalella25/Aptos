module myaddr::TokenWithBurnTax {
    use aptos_framework::signer;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;
    use aptos_framework::event;
    
    /// Struct representing a token with burn tax mechanism
    struct BurnTaxToken has store, key {
        total_supply: u64,        // Current total supply of tokens
        burned_amount: u64,       // Total tokens burned so far
        burn_tax_rate: u64,       // Burn tax rate in basis points (e.g., 200 = 2%)
        owner: address,           // Contract owner address
    }
    
    /// Event emitted when tokens are burned
    struct TokenBurnEvent has drop, store {
        from_address: address,
        amount_burned: u64,
        remaining_supply: u64,
    }
    
    /// Function to initialize the burn tax token system
    public fun initialize_token(
        owner: &signer, 
        initial_supply: u64, 
        burn_tax_rate: u64
    ) {
        let owner_addr = signer::address_of(owner);
        
        // Create the burn tax token with initial parameters
        let token = BurnTaxToken {
            total_supply: initial_supply,
            burned_amount: 0,
            burn_tax_rate, // 200 = 2%, 500 = 5%, etc.
            owner: owner_addr,
        };
        
        move_to(owner, token);
    }
    
    /// Function to transfer tokens with automatic burn tax deduction
    public fun transfer_with_burn(
        sender: &signer,
        token_owner: address,
        recipient: address,
        amount: u64
    ) acquires BurnTaxToken {
        let token = borrow_global_mut<BurnTaxToken>(token_owner);
        
        // Calculate burn amount (burn_tax_rate / 10000 * amount)
        let burn_amount = (amount * token.burn_tax_rate) / 10000;
        let transfer_amount = amount - burn_amount;
        
        // Burn tokens by reducing total supply
        token.total_supply = token.total_supply - burn_amount;
        token.burned_amount = token.burned_amount + burn_amount;
        
        // Transfer the remaining amount to recipient
        let coins_to_transfer = coin::withdraw<AptosCoin>(sender, transfer_amount);
        coin::deposit<AptosCoin>(recipient, coins_to_transfer);

    }
}