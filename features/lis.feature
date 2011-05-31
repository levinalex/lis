Feature:
  In order to diagnose patients correctly
  As a doctor
  I want to be able to receive test results via LIS

  Scenario: sending results from Immulite to LIS
    Given LIS Interface listening for messages
    When receiving data
    """
      1H|\^||PASSWORD|DPC||||SYSTEM||P|1|19940407085426
      2P|1|119813;TGH|||Last 1^First 1|||F|||||
      3O|1|130000445||^^^TT4|||19950118085700
      4R|1|^^^TT4|10.3|ug/dL|4.5\.4^12.5\24|N|N|F||test|19950119084508|19950119092826|SenderID
      5O|2|130000445||^^^TU|||19950118085700
      6R|1|^^^TU|26.6|Percnt|23\10^35\70|N|N|F||test|19950119084508|19950119092756|SenderID
      7P|2|325031;AH|||Last 2^First 2|||F|||||
      1O|1|130000617||^^^FER|||19950118103000
      2R|1|^^^FER|173.|ng/mL|.5\.5^1500\1500|N|N|F||test|19950119084641|19950119092858|SenderID
      3P|3|326829;AH|||Last 3^First 3|||F|||||
      4O|1|130000722||^^^FER|||19950118102000
      5R|1|^^^FER|490.|ng/mL|.5\.5^1500\1500|N|N|F||test|19950119084741|19950119092928|SenderID
      6P|4|124462;TGH|||Last 4^First 4|||F|||||
      7O|1|130000724||^^^E2|||19950118122000
      1R|1|^^^E2|25.3|pg/mL|12\12^2000\2000|N|N|F||test|19950119084815|19950119100049|SenderID
      2O|2|130000724||^^^FSH|||19950118122000
      3R|1|^^^FSH|60.6|mIU/mL|.1\.1^170\170|N|N|F||test|19950119084815|19950119093030|SenderID
      4O|3|130000724||^^^LH|||19950118122000
      5R|1|^^^LH|24.4|mIU/mL|.7\.7^400\400|N|N|F||test|19950119084815|19950119093101|SenderID
      6P|5|556395;AH|||Last 5^First 5|||M|||||
      7O|1|130000741||^^^FER|||19950118115500
      1R|1|^^^FER|238.|ng/mL|.5\.5^1500\1500|N|N|F||test|19950119084949|19950119093132|SenderID
      2P|6|556357;MB|||Last 6^First 6|||M|||||
      3O|1|130000790||^^^IGE|||19950118120000
      4R|1|^^^IGE|517.|IU/mL|.01\.01^600\600|N|N|F||test|19950119085018|19950119093202|SenderID
      5P|7|141053;TGH|||Last 7^First 7|||F|||||
      6O|1|130000805||^^^FER|||19950118120000
      7R|1|^^^FER|21.0|ng/mL|.5\.5^1500\1500|N|N|F||test|19950119085049|19950119093233|SenderID
      1P|8|320439;TGH|||Last 8^First 8|||F|||||
      2O|1|130000890||^^^FER|||19950118130000
      3R|1|^^^FER|12.9|ng/mL|.5\.5^1500\1500|N|N|F||test|19950119085254|19950119093609|SenderID
      4P|9||||Last 9^First 9||||||||
      5O|1|130000911||^^^E2
      6R|1|^^^E2|71.3|pg/mL|12\12^2000\2000|N|N|F||test|19950119085423|19950119100800|SenderID
      7P|10|358069;TGH|||Last 10^First 10|||F|||||
      1O|1|130000929||^^^FER|||19950118123000
      2R|1|^^^FER|219.|ng/mL|.5\.5^1500\1500|N|N|F||test|19950119085628|19950119093843|SenderID
      3L|1
    """
    Then the server should have acknowledged 39 packets
    Then should have posted results:
      | id            | test_name   | value  | unit   | status | flags | result_timestamp          |
      | DPC-130000445 | TT4         | 10.3   | ug/dL  | F      | N     | 1995-01-19T09:28:26+00:00 |
      | DPC-130000445 | TU          | 26.6   | Percnt | F      | N     | 1995-01-19T09:27:56+00:00 |
      | DPC-130000617 | FER         | 173.   | ng/mL  | F      | N     | 1995-01-19T09:28:58+00:00 |
      | DPC-130000722 | FER         | 490.   | ng/mL  | F      | N     | 1995-01-19T09:29:28+00:00 |
      | DPC-130000724 | E2          | 25.3   | pg/mL  | F      | N     | 1995-01-19T10:00:49+00:00 |


