
# 接口文档
## History 合约

### 1. 查询历史交易

[](./history.md)

## Token合约

### 1. 查询合约的总供应量

调用对应token合约的totalSupply方法

```aidl
function totalSupply() external view  returns (uint256)
```

abi:
```aidl
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


dToken总供应量，调用dToken合约的totalSupply方法； SDIP总供应量，调用SDIP合约的totalSupply方法。



### 2. 查询合约余额

```aidl
function balanceOf(address account) public view returns (uint256)
```

abi:
```aidl
    {
      "constant": true,
      "inputs": [
        {
          "internalType": "address",
          "name": "account",
          "type": "address"
        }
      ],
      "name": "balanceOf",
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

## 主页数据显示

### 1. 基础资产的总价值

1） 先获取系统的基础资产地址列表

调用resolver合约

```aidl
function getAssets(bytes32 assetType) external view returns (bytes32[] memory)
```

参数传入"Staker"，获取所有基础资产的合约地址列表。


2) 分别调用对应地址合约的balanceOf方法，获取合约的balance


```aidl
function balanceOf(address account) public view returns (uint256)
```
其中，参数account传入Synthx合约的地址(即send合约的地址)

abi:
```aidl
    {
      "constant": true,
      "inputs": [
        {
          "internalType": "address",
          "name": "account",
          "type": "address"
        }
      ],
      "name": "balanceOf",
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

3） 将结果累加，即基础资产的总价值

### 2. 合成资产的总价值

调用resolver合约

```aidl
function getAssets(bytes32 assetType) external view returns (bytes32[] memory)
```

参数传入"Synth"，获取所有合成资产的合约地址列表。


2) 分别调用对应地址合约的balanceOf方法，获取合约的balance


```aidl
function balanceOf(address account) public view returns (uint256)
```
其中，参数account传入Synthx合约的地址(即send合约的地址)

abi:
```aidl
    {
      "constant": true,
      "inputs": [
        {
          "internalType": "address",
          "name": "account",
          "type": "address"
        }
      ],
      "name": "balanceOf",
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
3） 将结果累加，即合成资产的总价值


### 3. 系统总抵押率

系统总抵押率 = 合成资产总价值  / 基础资产总价值  ；

结果展示成百分比

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

### 查询可提现数量

```aidl
function getTransferable(bytes32 token, address account) external view returns (uint256 staker) 
```

其中token为基础资产名字，account为帐户地址。


signature:```0x668187b8```

abi

```aidl
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
      "name": "getTransferable",
      "outputs": [
        {
          "internalType": "uint256",
          "name": "staker",
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
    dtokens: '200000000000000000',
    transferable: '2000000000000000001',
    balance: '999996637603276526373410000000000',
    price: '2000000000000000000000'
  ]
]
```

其中assetName为资产名，currentCollateralRate为当前抵押率，staked为仓位中质押的ETH数量, debt为仓位中质押出的dUSD数量, balance为账户中ETH余额，
price为ETH价格, dtokens为仓位分配的dtoken数量

2. 新债仓的抵押率为

假设deltaUSDAmount为新合成的dUSD数量，ETHDeltaAmount为新质押的ETH数量，则：

CollateralRate = (USDAmount + deltaUSDAmount) / ((ETHAmount + ETHDeltaAmount) * ETHPrice)

## Synthx合约

### 1. mint(发行 dUSD)

#### 1.1  如果基础资产是ETH, 调用如下接口
```cgo
function mintFromCoin(uint256 mintedAmount) external payable returns (bool)
```

abi
```cgo
{
      "constant": false,
      "inputs": [
        {
          "internalType": "uint256",
          "name": "mintedAmount",
          "type": "uint256"
        }
      ],
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

signature:```0x768ab0fc```

#### 1.2  如果基础资产是ERC20，调用如下接口
```cgo
function mintFromToken(bytes32 stake, uint256 amount, uint256 mintedAmount) external returns (bool) 
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
        },
        {
          "internalType": "uint256",
          "name": "mintedAmount",
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


signature: ```05635bc4```

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


### 增加保证金

向仓位中增加保证金，提升抵押率。

1. 如果是nativeCoin，调用stakeFromCoin接口

```cgo
function stakeFromCoin() external payable returns (bool)
```


abi

```cgo
    {
      "constant": false,
      "inputs": [],
      "name": "stakeFromCoin",
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


signature:
```cgo
0x74d770ac
```

2. 如果是ERC20， 调用stakeFromToken接口


```cgo
function stakeFromToken(bytes32 stake, uint256 amount) external returns (bool)
```
参数说明同mintFromToken， stake为资产名字的bytes32, amount为数量.


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
      "name": "stakeFromToken",
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
0xb307cce8
```

### 减少保证金

从仓位中取出基础资产，降低抵押率，取回的资产将转至钱包地址。

```cgo

    function transfer(
        bytes32 stake,
        address payable recipient,
        uint256 amount
    ) public returns (bool)
```

参数说明： stake为资产名称的bytes32, recipient为收币地址，amount为取回的资产数量。

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
          "internalType": "address payable",
          "name": "recipient",
          "type": "address"
        },
        {
          "internalType": "uint256",
          "name": "amount",
          "type": "uint256"
        }
      ],
      "name": "transfer",
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
3feb1bd8
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

### 获取K线

```aidl
function getLine(bytes32 asset, uint256 size) external view returns (uint256[] memory)
```

abi
```aidl
    {
      "constant": true,
      "inputs": [
        {
          "internalType": "bytes32",
          "name": "asset",
          "type": "bytes32"
        },
        {
          "internalType": "uint256",
          "name": "size",
          "type": "uint256"
        }
      ],
      "name": "getLine",
      "outputs": [
        {
          "internalType": "uint256[]",
          "name": "",
          "type": "uint256[]"
        }
      ],
      "payable": false,
      "stateMutability": "view",
      "type": "function"
    }
```

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


### 查询合成资产的交易量

调用Stats合约（即query合约）的getAssetMarket方法。

```aidl

    function getAssetMarket(bytes32 asset)
        external
        view
        returns (
            uint256 open,
            uint256 last,
            uint256 low,
            uint256 hight,
            uint256 volume,
            uint256 turnover
        )
```

参数传入合成资产的名字。返回结果中，volum表示成交量。

abi
```aidl
    {
      "constant": true,
      "inputs": [
        {
          "internalType": "bytes32",
          "name": "asset",
          "type": "bytes32"
        }
      ],
      "name": "getAssetMarket",
      "outputs": [
        {
          "internalType": "uint256",
          "name": "open",
          "type": "uint256"
        },
        {
          "internalType": "uint256",
          "name": "last",
          "type": "uint256"
        },
        {
          "internalType": "uint256",
          "name": "low",
          "type": "uint256"
        },
        {
          "internalType": "uint256",
          "name": "hight",
          "type": "uint256"
        },
        {
          "internalType": "uint256",
          "name": "volume",
          "type": "uint256"
        },
        {
          "internalType": "uint256",
          "name": "turnover",
          "type": "uint256"
        }
      ],
      "payable": false,
      "stateMutability": "view",
      "type": "function"
    }
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


附：

测试网合约地址：


```aidl

全新的合约地址，已经出炉了：

{
	"setting": "0x2Ce99c27D75a45D8a84ce90B75d6e4008b3D2479",
	"resolver": "0x24315bFF961323087B06be58f2aC039Ed273A59c",
	"issuer": "0xBD505a2d0174611242E977e2FA624523062560A3",
	"history": "0xeB81638c9F95F31b7B1A7d4e15bAc369670Cf0ac",
	"liquidator": "0x9a22e31a8593B06c64a401060ADF252e8325c9a7",
	"staker": "0x3d0eDEbA704199261C38852594aC9A0CDCB5bd3A",
	"holder": "0x096f7Ddd1a36f2c72199034d295e6C08186aFB3C",
	"assetPrice": "0x117D754351F06E232beb1b947200F8C55b0B6A23",
	"trader": "0x4C3c55e63585855B3bB7176F05A99F58daB0D22B",
	"market": "0x3577e8F60AD9b6173714534B94c17328e3c463C7",
	"supplySchedule": "0xc2c9bB685641bcD897DF1C2fB85C2aB95e808e14",
	"stats": "0x2AeCFA992157753CE6c251933EBEA5a594de83E5",
	"synthx": "0xBDDc06115C9D86B1530839FEC306E3A03e93f730",
	"synthxOracle": "0x0cc7b0A21cfFB813eDE40304dd078AE72fF123EE",
	"chainLinkOracle": "0x34C39085B339cE2615f9E9fA6eE8296E4b48C24C",
	"dUSD": "0xcc303787007A504b4e4c4A685303ca104E74e264",
	"synthxToken": "0x327eDB4986aac59d03CB6fAF158dAF2a50b29BBA",
	"synthxDToken": "0xfD7eD4eed7849e6f2EDd3CF863B826CbCDA65112",
	"dTSLA": "0x56d26f0801B4cCBAac272895cc4b0f7BFA81Ca45",
	"dAPPL": "0xE094572d9c5e3699269EF9F6D42d7522AE7B8608"
}
```