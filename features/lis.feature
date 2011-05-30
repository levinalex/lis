Feature:
  In order to value
  As a role
  I want feature

  Scenario: sending results from Immulite to LIS
    Given LIS Interface listening for messages
    When receiving
    """
      H|\^||PASSWORD|DPC||||SYSTEM||P|1|19940407085426
      P|1|119813;TGH|||Last 1^First 1|||F|||||
      O|1|130000445||^^^TT4|||19950118085700
      R|1|^^^TT4|10.3|ug/dL|4.5\.4^12.5\24|N|N|F||test|19950119084508|19950119092826|SenderID
      O|2|130000445||^^^TU|||19950118085700
      R|1|^^^TU|26.6|Percnt|23\10^35\70|N|N|F||test|19950119084508|19950119092756|SenderID
      P|2|325031;AH|||Last 2^First 2|||F|||||
      O|1|130000617||^^^FER|||19950118103000
      R|1|^^^FER|173.|ng/mL|.5\.5^1500\1500|N|N|F||test|19950119084641|19950119092858|SenderID
      P|3|326829;AH|||Last 3^First 3|||F|||||
      O|1|130000722||^^^FER|||19950118102000
      R|1|^^^FER|490.|ng/mL|.5\.5^1500\1500|N|N|F||test|19950119084741|19950119092928|SenderID
      P|4|124462;TGH|||Last 4^First 4|||F|||||
      O|1|130000724||^^^E2|||19950118122000
      R|1|^^^E2|25.3|pg/mL|12\12^2000\2000|N|N|F||test|19950119084815|19950119100049|SenderID
      O|2|130000724||^^^FSH|||19950118122000
      R|1|^^^FSH|60.6|mIU/mL|.1\.1^170\170|N|N|F||test|19950119084815|19950119093030|SenderID
      O|3|130000724||^^^LH|||19950118122000
      R|1|^^^LH|24.4|mIU/mL|.7\.7^400\400|N|N|F||test|19950119084815|19950119093101|SenderID
      P|5|556395;AH|||Last 5^First 5|||M|||||
      O|1|130000741||^^^FER|||19950118115500
      R|1|^^^FER|238.|ng/mL|.5\.5^1500\1500|N|N|F||test|19950119084949|19950119093132|SenderID
      P|6|556357;MB|||Last 6^First 6|||M|||||
      O|1|130000790||^^^IGE|||19950118120000
      R|1|^^^IGE|517.|IU/mL|.01\.01^600\600|N|N|F||test|19950119085018|19950119093202|SenderID
      P|7|141053;TGH|||Last 7^First 7|||F|||||
      O|1|130000805||^^^FER|||19950118120000
      R|1|^^^FER|21.0|ng/mL|.5\.5^1500\1500|N|N|F||test|19950119085049|19950119093233|SenderID
      P|8|320439;TGH|||Last 8^First 8|||F|||||
      O|1|130000890||^^^FER|||19950118130000
      R|1|^^^FER|12.9|ng/mL|.5\.5^1500\1500|N|N|F||test|19950119085254|19950119093609|SenderID
      P|9||||Last 9^First 9||||||||
      O|1|130000911||^^^E2
      R|1|^^^E2|71.3|pg/mL|12\12^2000\2000|N|N|F||test|19950119085423|19950119100800|SenderID
      P|10|358069;TGH|||Last 10^First 10|||F|||||
      O|1|130000929||^^^FER|||19950118123000
      R|1|^^^FER|219.|ng/mL|.5\.5^1500\1500|N|N|F||test|19950119085628|19950119093843|SenderID
      L|1
    """
    Then should have posted results:
      | device_name | barcode |