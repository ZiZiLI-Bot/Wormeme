use anchor_lang::prelude::*;
use anchor_lang::system_program::{transfer, Transfer};

declare_id!("6mTRMkmrphK3Wn9XgLAvDuPRSxynJ696wtdF4QRReuHk");
#[program]
pub mod wormeme_vault {
    use super::*;
    pub fn initialize(ctx: Context<InitializeContext>) -> Result<()> {
        ctx.accounts.state.contract_owner = ctx.accounts.owner.key();
        ctx.accounts.state.owner = ctx.accounts.owner.key();
        ctx.accounts.state.state_bump = ctx.bumps.state;
        ctx.accounts.state.auth_bump = ctx.bumps.auth;
        ctx.accounts.state.vault_bump = ctx.bumps.vault;
        Ok(())
    }

    pub fn deposit(ctx: Context<DepositContext>, amount: u64) -> Result<()> {
        let transfer_accounts = Transfer {
            from: ctx.accounts.owner.to_account_info(),
            to: ctx.accounts.vault.to_account_info(),
        };
        let cpi_ctx = CpiContext::new(
            ctx.accounts.system_program.to_account_info(),
            transfer_accounts,
        );
        transfer(cpi_ctx, amount)?;
        Ok(())
    }

    pub fn withdraw(ctx: Context<WithdrawContext>, amount: u64) -> Result<()> {
        // Only the owner can withdraw
        require_keys_eq!(ctx.accounts.owner.key(), ctx.accounts.state.contract_owner);

        let transfer_accounts = Transfer {
            from: ctx.accounts.vault.to_account_info(),
            to: ctx.accounts.owner.to_account_info(),
        };
        let seeds = &[
            b"vault",
            ctx.accounts.auth.to_account_info().key.as_ref(),
            &[ctx.accounts.state.vault_bump],
        ];
        let pda_signer = &[&seeds[..]];
        let cpi_ctx = CpiContext::new_with_signer(
            ctx.accounts.system_program.to_account_info(),
            transfer_accounts,
            pda_signer,
        );
        transfer(cpi_ctx, amount)?;
        Ok(())
    }
}

#[derive(Accounts)]
pub struct InitializeContext<'info> {
    #[account(mut)]
    pub owner: Signer<'info>,
    #[account(
        init,
        payer = owner,
        space = 43,
        seeds = [b"state",
        owner.key().as_ref()],
        bump,
    )]
    pub state: Account<'info, Vault>,
    #[account(seeds = [b"auth", state.key().as_ref()], bump)]
    /// CHECK: This acc is safe
    pub auth: UncheckedAccount<'info>,
    #[account(mut, seeds = [b"vault", auth.key().as_ref()], bump)]
    pub vault: SystemAccount<'info>,
    pub system_program: Program<'info, System>,
}

#[derive(Accounts)]
pub struct DepositContext<'info> {
    #[account(mut)]
    pub owner: Signer<'info>,
    #[account(seeds = [b"auth", state.key().as_ref()], bump = state.auth_bump)]
    /// CHECK: This acc is safe
    pub auth: UncheckedAccount<'info>,
    #[account(seeds = [b"state", owner.key().as_ref()], bump = state.state_bump)]
    pub state: Account<'info, Vault>,
    #[account(mut, seeds = [b"vault", auth.key().as_ref()], bump = state.vault_bump)]
    pub vault: SystemAccount<'info>,
    pub system_program: Program<'info, System>,
}

#[derive(Accounts)]
pub struct WithdrawContext<'info> {
    #[account(mut, seeds = [b"vault", auth.key().as_ref()], bump = state.vault_bump)]
    pub vault: SystemAccount<'info>,
    #[account(mut)]
    pub owner: Signer<'info>,
    #[account(seeds = [b"auth", state.key().as_ref()], bump = state.auth_bump)]
    /// CHECK: This acc is safe
    pub auth: UncheckedAccount<'info>,
    #[account(seeds = [b"state", owner.key().as_ref()], bump = state.state_bump)]
    pub state: Account<'info, Vault>,
    pub system_program: Program<'info, System>,
}

#[account]
pub struct Vault {
    pub contract_owner: Pubkey,
    pub owner: Pubkey,
    pub state_bump: u8,
    pub auth_bump: u8,
    pub vault_bump: u8,
}
