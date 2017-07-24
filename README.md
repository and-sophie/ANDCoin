# ANDCoin

My attempt to create a blockchain network for trading ANDCoins.

This is a learning exercise to familiarize myself with IBM Hyperledger Fabric.

## How to Use

Clone this repository

```
git clone
```

cd into the directory, create a new folder 'bin' then use this script to download the binaries (into the bin directory) and docker images.

```
cd ANDcoin
mkdir bin
curl -sSL https://goo.gl/iX9dek | bash
```

## User Stories

```
As an ANDi
I want to join the network using my email address and name
So that I can trade ANDCoins
```
```
As an ANDi
I want to have a default balance of 100AC
So that I can trade with other ANDis
```
```
As an ANDi
I want to see the ledger of all transactions
So that I can see what transactions have been made on the network
```
```
As an ANDi
I want to be able to send money to another User
So that I can buy goods
```
```
As an ANDi
I don't want to be able to spend more ANDCoins than I have
So I don't accidentally overspend
```
```
As an ANDi
I want to be able to accept money from another user
So that I can sell goods
```
```
As an ANDi
I want my balance to reflect debits and credits
So that I can see how many ANDCoins I have to spend
```
