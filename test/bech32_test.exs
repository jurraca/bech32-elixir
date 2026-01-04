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
end
