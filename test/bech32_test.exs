defmodule Bech32Test do
  use ExUnit.Case
  doctest Bech32

  test "encoding" do
    addr = Bech32.encode("ckt", <<1, 0, 248, 233, 196, 92, 241, 52, 177, 249, 178, 100, 1, 226, 254, 133, 46, 33, 214, 246, 151, 234>>)
    assert addr === "ckt1qyq036wytncnfv0ekfjqrch7s5hzr4hkjl4qd3tkj9"
  end

  test "decoding" do
    assert {:ok, "ckb", <<1, 0, 248, 233, 196, 92, 241, 52, 177, 249, 178, 100, 1, 226, 254, 133, 46, 33, 214, 246, 151, 234>>} === Bech32.decode("ckb1qyq036wytncnfv0ekfjqrch7s5hzr4hkjl4qs54f7e")
  end

  test "ignore_length option allows addresses over 90 characters" do
    # Create a long data payload (50 bytes = 80 chars in bech32 encoding, plus hrp and checksum > 90)
    long_data = :binary.copy(<<1, 2, 3, 4, 5>>, 10)
    long_addr = Bech32.encode("ckb", long_data)

    # Verify the address is actually over 90 characters
    assert byte_size(long_addr) > 90

    # Without ignore_length, should fail
    assert {:error, :too_long} = Bech32.decode(long_addr)

    # With ignore_length: true, should succeed
    assert {:ok, "ckb", _data} = Bech32.decode(long_addr, ignore_length: true)
  end

  describe "BIP-173 valid Bech32 test vectors" do
    test "uppercase A12UEL5L (lowercased for verify)" do
      assert :ok = Bech32.verify(String.downcase("A12UEL5L"))
    end

    test "lowercase a12uel5l" do
      assert :ok = Bech32.verify("a12uel5l")
    end

    test "83 character HRP with excluded chars in name" do
      assert :ok = Bech32.verify("an83characterlonghumanreadablepartthatcontainsthenumber1andtheexcludedcharactersbio1tt5tgs")
    end

    test "abcdef with full charset in data" do
      assert :ok = Bech32.verify("abcdef1qpzry9x8gf2tvdw0s3jn54khce6mua7lmqqqxw")
    end

    test "HRP of 1 with long data" do
      assert :ok = Bech32.verify("11qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqc8247j")
    end

    test "split checkup address" do
      assert :ok = Bech32.verify("split1checkupstagehandshakeupstreamerranterredcaperred2y9e3w")
    end
  end

  describe "BIP-173 invalid Bech32 test vectors" do
    test "84 chars - overall max length exceeded" do
      assert {:error, :too_long} = Bech32.decode("an84characterslonghumanreadablepartthatcontainsthenumber1andtheexcludedcharactersbio1569pvx")
    end

    test "no separator character" do
      assert {:error, :no_separator} = Bech32.decode("pzry9x0s0muk")
    end

    test "empty HRP (1 at start)" do
      assert {:error, :no_hrp} = Bech32.decode("1pzry9x0s0muk")
    end

    test "invalid data character (b)" do
      assert {:error, :not_in_charset} = Bech32.decode("x1b4n0q5v")
    end

    test "too short checksum" do
      assert {:error, :checksum_too_short} = Bech32.decode("li1dgmt3")
    end

    test "checksum calculated with uppercase form of HRP" do
      assert {:error, :checksum_failed} = Bech32.decode("A1G7SGD8")
    end

    test "empty HRP - 10a06t8" do
      assert {:error, :no_hrp} = Bech32.decode("10a06t8")
    end

    test "empty HRP - 1qzzfhee" do
      assert {:error, :no_hrp} = Bech32.decode("1qzzfhee")
    end

    test "HRP character out of range (0x20 space)" do
      assert {:error, :invalid_char} = Bech32.decode(" 1nwldj5")
    end

    test "mixed case" do
      assert {:error, :mixed_case_char} = Bech32.decode("A1a")
    end
  end

  describe "BIP-173 valid SegWit test vectors" do
    test "BC1QW508D6QEJXTDG4Y5R3ZARVARY0C5XW7KV8F3T4" do
      {:ok, witver, data} = Bech32.segwit_decode("bc", "BC1QW508D6QEJXTDG4Y5R3ZARVARY0C5XW7KV8F3T4")
      assert witver == 0
      assert Base.encode16(data, case: :lower) == "751e76e8199196d454941c45d1b3a323f1433bd6"
    end

    test "tb1qrp33g0q5c5txsp9arysrx4k6zdkfs4nce4xj0gdcccefvpysxf3q0sl5k7" do
      {:ok, witver, data} = Bech32.segwit_decode("tb", "tb1qrp33g0q5c5txsp9arysrx4k6zdkfs4nce4xj0gdcccefvpysxf3q0sl5k7")
      assert witver == 0
      assert Base.encode16(data, case: :lower) == "1863143c14c5166804bd19203356da136c985678cd4d27a1b8c6329604903262"
    end

    test "BC1SW50QA3JX3S" do
      {:ok, witver, data} = Bech32.segwit_decode("bc", "BC1SW50QA3JX3S")
      assert witver == 16
      assert Base.encode16(data, case: :lower) == "751e"
    end

    test "bc1zw508d6qejxtdg4y5r3zarvaryvg6kdaj" do
      {:ok, witver, data} = Bech32.segwit_decode("bc", "bc1zw508d6qejxtdg4y5r3zarvaryvg6kdaj")
      assert witver == 2
      assert Base.encode16(data, case: :lower) == "751e76e8199196d454941c45d1b3a323"
    end

    test "tb1qqqqqp399et2xygdj5xreqhjjvcmzhxw4aywxecjdzew6hylgvsesrxh6hy" do
      {:ok, witver, data} = Bech32.segwit_decode("tb", "tb1qqqqqp399et2xygdj5xreqhjjvcmzhxw4aywxecjdzew6hylgvsesrxh6hy")
      assert witver == 0
      assert Base.encode16(data, case: :lower) == "000000c4a5cad46221b2a187905e5266362b99d5e91c6ce24d165dab93e86433"
    end
  end

  describe "BIP-173 invalid SegWit test vectors" do
    test "invalid HRP (tc instead of tb or bc)" do
      assert {:error, :wrong_hrp} = Bech32.segwit_decode("bc", "tc1qw508d6qejxtdg4y5r3zarvary0c5xw7kg3g4ty")
    end

    test "invalid checksum" do
      assert {:error, :checksum_failed} = Bech32.segwit_decode("bc", "bc1qw508d6qejxtdg4y5r3zarvary0c5xw7kv8f3t5")
    end

    test "invalid witness version (31)" do
      assert {:error, :invalid_witness_version} = Bech32.segwit_decode("bc", "BC13W508D6QEJXTDG4Y5R3ZARVARY0C5XW7KN40WF2")
    end

    test "invalid program length (too short)" do
      assert {:error, :invalid_size} = Bech32.segwit_decode("bc", "bc1rw5uspcuh")
    end

    test "invalid program length (too long)" do
      assert {:error, :invalid_size} = Bech32.segwit_decode("bc", "bc10w508d6qejxtdg4y5r3zarvary0c5xw7kw508d6qejxtdg4y5r3zarvary0c5xw7kw5rljs90")
    end

    test "invalid program length for witness version 0" do
      assert {:error, :invalid_size} = Bech32.segwit_decode("bc", "BC1QR508D6QEJXTDG4Y5R3ZARVARYV98GJ9P")
    end

    test "mixed case in address" do
      assert {:error, :mixed_case_char} = Bech32.segwit_decode("tb", "tb1qrp33g0q5c5txsp9arysrx4k6zdkfs4nce4xj0gdcccefvpysxf3q0sL5k7")
    end

    test "empty data section" do
      assert {:error, _reason} = Bech32.segwit_decode("bc", "bc1gmk9yu")
    end
  end

end
