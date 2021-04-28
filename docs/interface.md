
# 接口文档


## Setting合约

### 1. 查询基础资产的最低抵押率

```cgo
function getCollateralRate(bytes32 asset) external view returns (uint256);
```

合成资产时，仓位抵押率不得低于此值。其中asset传入资产名字的bytes32, 例如ETH的bytes32:

```cgo
0x4554480000000000000000000000000000000000000000000000000000000000
```


abi

```cgo
    {
      "constant": true,
      "inputs": [
        {
          "internalType": "bytes32",
          "name": "asset",
          "type": "bytes32"
        }
      ],
      "name": "getCollateralRate",
      "outputs": [
        {
          "internalType": "uint256",
          "name": "",
          "type": "uint256"
        }
      ],
      "payable": false,
      "stateMutability": "view",
      "type": "function"
    }
```

## Staker合约

### 获取账户的抵押率

指定资产名字和帐户地址，查询帐户的仓位抵押率。

```cgo
function getCollateralRate(bytes32 token, address account)
```

abi

```cgo
    {
      "constant": true,
      "inputs": [
        {
          "internalType": "bytes32",
          "name": "token",
          "type": "bytes32"
        },
        {
          "internalType": "address",
          "name": "account",
          "type": "address"
        }
      ],
      "name": "getCollateralRate",
      "outputs": [
        {
          "internalType": "uint256",
          "name": "",
          "type": "uint256"
        }
      ],
      "payable": false,
      "stateMutability": "view",
      "type": "function"
    }
```


## Issuer合约

### 查询账户负债

指定基础资产，查询负债

```cgo
function getDebt(bytes32 stake, address account) external view returns (uint256) 
```

abi
```cgo
    {
      "constant": true,
      "inputs": [
        {
          "internalType": "bytes32",
          "name": "stake",
          "type": "bytes32"
        },
        {
          "internalType": "address",
          "name": "account",
          "type": "address"
        }
      ],
      "name": "getDebt",
      "outputs": [
        {
          "internalType": "uint256",
          "name": "",
          "type": "uint256"
        }
      ],
      "payable": false,
      "stateMutability": "view",
      "type": "function"
    }
```

### 查询系统总债务

```cgo
function getTotalDebt() public view returns (uint256)
```

abi
```cgo
   {
      "constant": true,
      "inputs": [],
      "name": "getTotalDebt",
      "outputs": [
        {
          "internalType": "uint256",
          "name": "",
          "type": "uint256"
        }
      ],
      "payable": false,
      "stateMutability": "view",
      "type": "function"
    }
```

### 如何在前端计算用户的仓位抵押率

#### 首次mint时，前端展示的用户他们抵押率

以ETH为例，假如用户质押的ETH数量为 ETHAmount， 质押出的dUSD数量为dUSDAmount，那么ETH的价格ETHPrice可以通过getAssets获取, dUSD的价格恒定为1000000000000000000

CollateralRate = (dUSDAmount * 1) / (ETHAmount * ETHPrice)

### 非首次mint，前端展示的用户抵押率

以ETH为例

1. 先调用getVaults接口，获取用户的债仓信息，返回结果类似如下：

```cgo
 [
  [
    assetName: '0x4554480000000000000000000000000000000000000000000000000000000000',
    assetAddress: '0xEa3ED7E36aBb9AC0Adb61c58359Be48Ad87C3bCC',
    currentCollateralRate: '2222222222222222222',
    rewardCollateralRate: '2000000000000000000',
    liquidationCollateralRate: '1000000000000000000',
    liquidationFeeRate: '0',
    staked: '20000000000000000000',
    debt: '17999999999999999999750',
    transferable: '2000000000000000001',
    balance: '999996637603276526373410000000000',
    price: '2000000000000000000000'
  ]
]
```

其中assetName为资产名，currentCollateralRate为当前抵押率，staked为仓位中质押的ETH数量, debt为仓位中质押出的dUSD数量, balance为账户中ETH余额，
price为ETH价格

2. 新债仓的抵押率为

假设deltaUSDAmount为新合成的dUSD数量，ETHDeltaAmount为新质押的ETH数量，则：

CollateralRate = (USDAmount + deltaUSDAmount) / ((ETHAmount + ETHDeltaAmount) * ETHPrice)

## Synthx合约

### 1. mint(发行 dUSD)

#### 1.1  如果基础资产是ETH, 调用如下接口
```cgo
 function mintFromCoin() external payable returns (bool)
```

abi
```cgo
    {
      "constant": false,
      "inputs": [],
      "name": "mintFromCoin",
      "outputs": [
        {
          "internalType": "bool",
          "name": "",
          "type": "bool"
        }
      ],
      "payable": true,
      "stateMutability": "payable",
      "type": "function"
    }
```

#### 1.2  如果基础资产是ERC20，调用如下接口
```cgo
function mintFromToken(bytes32 stake, uint256 amount) external returns (bool)
```

abi
```cgo
    {
      "constant": false,
      "inputs": [
        {
          "internalType": "bytes32",
          "name": "stake",
          "type": "bytes32"
        },
        {
          "internalType": "uint256",
          "name": "amount",
          "type": "uint256"
        }
      ],
      "name": "mintFromToken",
      "outputs": [
        {
          "internalType": "bool",
          "name": "",
          "type": "bool"
        }
      ],
      "payable": false,
      "stateMutability": "nonpayable",
      "type": "function"
    }
```
参数说明：

stake为资产名字，bytes32类型。


ERC20合约，需要先授权。即调用对应ERC20合约的approve方法:

```cgo
function approve(address spender, uint256 amount) returns (bool)
```

abi:

```cgo
   {
      "constant": false,
      "inputs": [
        {
          "internalType": "address",
          "name": "spender",
          "type": "address"
        },
        {
          "internalType": "uint256",
          "name": "amount",
          "type": "uint256"
        }
      ],
      "name": "approve",
      "outputs": [
        {
          "internalType": "bool",
          "name": "",
          "type": "bool"
        }
      ],
      "payable": false,
      "stateMutability": "nonpayable",
      "type": "function"
    }
```

signature: ```0x095ea7b3```


### 销毁 dUSD

```
function burn(bytes32 stake, uint256 amount) external onlyInitialized notPaused returns (bool)
```

abi
```cgo
    {
      "constant": false,
      "inputs": [
        {
          "internalType": "bytes32",
          "name": "stake",
          "type": "bytes32"
        },
        {
          "internalType": "uint256",
          "name": "amount",
          "type": "uint256"
        }
      ],
      "name": "burn",
      "outputs": [
        {
          "internalType": "bool",
          "name": "",
          "type": "bool"
        }
      ],
      "payable": false,
      "stateMutability": "nonpayable",
      "type": "function"
    }
```

signature:
```cgo
0x7a408454
```

### 领取收益

```cgo
function claimReward() external onlyInitialized notPaused returns (bool)
```

abi
```cgo
    {
      "constant": false,
      "inputs": [],
      "name": "claimReward",
      "outputs": [
        {
          "internalType": "bool",
          "name": "",
          "type": "bool"
        }
      ],
      "payable": false,
      "stateMutability": "nonpayable",
      "type": "function"
    }
```


### 交易

```cgo
 function trade(
        bytes32 fromSynth,
        uint256 fromAmount,
        bytes32 toSynth
    ) external onlyInitialized notPaused returns (bool)
```


abi
```cgo
    {
      "constant": false,
      "inputs": [
        {
          "internalType": "bytes32",
          "name": "fromSynth",
          "type": "bytes32"
        },
        {
          "internalType": "uint256",
          "name": "fromAmount",
          "type": "uint256"
        },
        {
          "internalType": "bytes32",
          "name": "toSynth",
          "type": "bytes32"
        }
      ],
      "name": "trade",
      "outputs": [
        {
          "internalType": "bool",
          "name": "",
          "type": "bool"
        }
      ],
      "payable": false,
      "stateMutability": "nonpayable",
      "type": "function"
    }
```

## Stats合约

### 查询账户收益

```cgo
function getRewards(address account) external view returns (uint256)
```

abi

```cgo
   {
      "constant": true,
      "inputs": [
        {
          "internalType": "address",
          "name": "account",
          "type": "address"
        }
      ],
      "name": "getRewards",
      "outputs": [
        {
          "internalType": "uint256",
          "name": "",
          "type": "uint256"
        }
      ],
      "payable": false,
      "stateMutability": "view",
      "type": "function"
    }
```

### 查询账户资产

```cgo
function getAssets(bytes32 assetType, address account) external view returns (Asset[] memory)
```

abi

```cgo
    {
      "constant": true,
      "inputs": [
        {
          "internalType": "bytes32",
          "name": "assetType",
          "type": "bytes32"
        },
        {
          "internalType": "address",
          "name": "account",
          "type": "address"
        }
      ],
      "name": "getAssets",
      "outputs": [
        {
          "components": [
            {
              "internalType": "bytes32",
              "name": "assetName",
              "type": "bytes32"
            },
            {
              "internalType": "address",
              "name": "assetAddress",
              "type": "address"
            },
            {
              "internalType": "bytes32",
              "name": "category",
              "type": "bytes32"
            },
            {
              "internalType": "uint256",
              "name": "balance",
              "type": "uint256"
            },
            {
              "internalType": "uint256",
              "name": "price",
              "type": "uint256"
            },
            {
              "internalType": "uint256",
              "name": "status",
              "type": "uint256"
            }
          ],
          "internalType": "struct IStats.Asset[]",
          "name": "",
          "type": "tuple[]"
        }
      ],
      "payable": false,
      "stateMutability": "view",
      "type": "function"
    }
```

Asset结构如下：

```    struct Asset {
        bytes32 assetName;
        address assetAddress;
        bytes32 category;
        uint256 balance;
        uint256 price;
        uint256 status;
    }
```

参数说明：

assetType 为Synth时，返回账户中的合成资产；assetType为Stake时，返回账户中的基础资产。

返回示例：

```cgo
 [
  [
    assetName: '0x6455534400000000000000000000000000000000000000000000000000000000',
    assetAddress: '0xB9e946d00cECA36a527D354C423BaB96C0E977Ee',
    category: '0x6572633230000000000000000000000000000000000000000000000000000000',
    balance: '8000000000000000000000',
    price: '1000000000000000000',
    status: '0'
  ],
  [
    assetName: '0x6454534c41000000000000000000000000000000000000000000000000000000',
    assetAddress: '0xdeE2c551e57b0a0aaCe9FEC499907605696e998a',
    category: '0x3200000000000000000000000000000000000000000000000000000000000000',
    balance: '333333333333333333',
    price: '750000000000000000000',
    status: '0'
  ],
  [
    assetName: '0x644150504c450000000000000000000000000000000000000000000000000000',
    assetAddress: '0x6170c8591B6f7F0ad017c742fCD125beA67d336B',
    category: '0x3200000000000000000000000000000000000000000000000000000000000000',
    balance: '65000000000000000000',
    price: '150000000000000000000',
    status: '0'
  ]
]

```

### 查询账户合成资产总价值
```cgo
function getSynthValue(address account) external view returns (uint256)
```

abi
```cgo
    {
      "constant": true,
      "inputs": [
        {
          "internalType": "address",
          "name": "account",
          "type": "address"
        }
      ],
      "name": "getSynthValue",
      "outputs": [
        {
          "internalType": "uint256",
          "name": "",
          "type": "uint256"
        }
      ],
      "payable": false,
      "stateMutability": "view",
      "type": "function"
    }
 ```

### 查询账户总债务

```cgo
function getTotalCollateral(address account)
        external
        view
        returns (
            uint256 totalCollateralRatio,
            uint256 totalCollateralValue,
            uint256 totalDebt
        )
```

abi

```cgo
    {
      "constant": true,
      "inputs": [
        {
          "internalType": "address",
          "name": "account",
          "type": "address"
        }
      ],
      "name": "getTotalCollateral",
      "outputs": [
        {
          "internalType": "uint256",
          "name": "totalCollateralRatio",
          "type": "uint256"
        },
        {
          "internalType": "uint256",
          "name": "totalCollateralValue",
          "type": "uint256"
        },
        {
          "internalType": "uint256",
          "name": "totalDebt",
          "type": "uint256"
        }
      ],
      "payable": false,
      "stateMutability": "view",
      "type": "function"
    }
```
### 查询账户债仓

```cgo
function getVaults(address account) public view returns (Vault[] memory)
```

abi

```cgo
 {
      "constant": true,
      "inputs": [
        {
          "internalType": "address",
          "name": "account",
          "type": "address"
        }
      ],
      "name": "getVaults",
      "outputs": [
        {
          "components": [
            {
              "internalType": "bytes32",
              "name": "assetName",
              "type": "bytes32"
            },
            {
              "internalType": "address",
              "name": "assetAddress",
              "type": "address"
            },
            {
              "internalType": "uint256",
              "name": "currentCollateralRate",
              "type": "uint256"
            },
            {
              "internalType": "uint256",
              "name": "rewardCollateralRate",
              "type": "uint256"
            },
            {
              "internalType": "uint256",
              "name": "liquidationCollateralRate",
              "type": "uint256"
            },
            {
              "internalType": "uint256",
              "name": "liquidationFeeRate",
              "type": "uint256"
            },
            {
              "internalType": "uint256",
              "name": "staked",
              "type": "uint256"
            },
            {
              "internalType": "uint256",
              "name": "debt",
              "type": "uint256"
            },
            {
              "internalType": "uint256",
              "name": "transferable",
              "type": "uint256"
            },
            {
              "internalType": "uint256",
              "name": "balance",
              "type": "uint256"
            },
            {
              "internalType": "uint256",
              "name": "price",
              "type": "uint256"
            }
          ],
          "internalType": "struct IStats.Vault[]",
          "name": "",
          "type": "tuple[]"
        }
      ],
      "payable": false,
      "stateMutability": "view",
      "type": "function"
    },
```
返回结果示例：

```cgo
 [
  [
    assetName: '0x4554480000000000000000000000000000000000000000000000000000000000',
    assetAddress: '0xEa3ED7E36aBb9AC0Adb61c58359Be48Ad87C3bCC',
    currentCollateralRate: '2222222222222222222',
    rewardCollateralRate: '2000000000000000000',
    liquidationCollateralRate: '1000000000000000000',
    liquidationFeeRate: '0',
    staked: '20000000000000000000',
    debt: '17999999999999999999750',
    transferable: '2000000000000000001',
    balance: '999996637603276526373410000000000',
    price: '2000000000000000000000'
  ]
]

```


### burn时，根据要burn的dToken数量，查询需要burn的dUSD数量

假设要burn的dToken数量为dTokenAmount

1. 查询dToken合约的总量，记为totalSupply

```cgo
function totalSupply() external view  returns (uint256)
```

abi:
```cgo
    {
      "constant": true,
      "inputs": [],
      "name": "totalSupply",
      "outputs": [
        {
          "internalType": "uint256",
          "name": "",
          "type": "uint256"
        }
      ],
      "payable": false,
      "stateMutability": "view",
      "type": "function"
    }
```

2. 查询系统总债务，记为totalDebt

查询方法见```查询系统总债务```

3. 需要burn的dUSD数量为

dUSDAmount = (dTokenAmount / totalSupply) * totalDebt