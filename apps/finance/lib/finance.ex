defmodule BCT do
  @moduledoc ~S"""
  Contains main business logic of the project.

  `BCT` is used by `BctWeb` and `Backoffice` Phoenix apps.

  See `BCT.Ledger` for a double-entry accounting system implementation.
  """

  use BCT.Model

  ## Customers

  def create_customer!(username, email) do
    Customer.build(%{username: username, email: email})
    |> Repo.insert!
  end

  def register_customer(username, email, password) do
    BCT.CustomerRegistration.create(username, email, password)
  end

  def find_customer!(clauses) do
    Repo.get_by!(Customer, clauses)
    |> Repo.preload(:wallet)
  end

  def customers do
    Repo.all(Customer)
  end

  ## Deposits

  def create_deposit!(account, amount) do
    {:ok, result} =
      Deposit.build(account, amount)
      |> Ledger.write
    result
  end

  ## Ledger

  @doc ~S"""
  Returns balance of the customer's wallet account
  """
  def balance(%Customer{wallet: wallet}), do: Ledger.balance(wallet)

  @doc ~S"""
  Returns transactions of the customer's wallet account.
  """
  def transactions(%Customer{wallet: wallet}), do: Ledger.entries(wallet)

  ## Transfers

  def build_transfer(customer) do
    Transfer.changeset(customer, %Transfer{})
  end

  def create_transfer(customer, params) do
    Transfer.create(customer, params)
  end
end
