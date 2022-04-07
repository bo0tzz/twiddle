defmodule Twiddle.M3U8Test do
  use ExUnit.Case

  alias Twiddle.M3U8

  @moduletag :capture_log

  @m3u8_body "#EXTM3U\n#EXT-X-VERSION:3\n#EXT-X-STREAM-INF:BANDWIDTH=921600,RESOLUTION=1280x720\nhttps://dgeft87wbj63p.cloudfront.net/73beaf75f7ac5dbcda3b_wirtual_44960203756_1647255903/720p60/index-dvr.m3u8\n\n#EXT-X-STREAM-INF:BANDWIDTH=1843200,RESOLUTION=1280x720\nhttps://dgeft87wbj63p.cloudfront.net/73beaf75f7ac5dbcda3b_wirtual_44960203756_1647255903/720p30/index-dvr.m3u8\n\n#EXT-X-STREAM-INF:BANDWIDTH=1226880,RESOLUTION=852x480\nhttps://dgeft87wbj63p.cloudfront.net/73beaf75f7ac5dbcda3b_wirtual_44960203756_1647255903/480p30/index-dvr.m3u8\n\n#EXT-X-STREAM-INF:BANDWIDTH=921600,RESOLUTION=640x360\nhttps://dgeft87wbj63p.cloudfront.net/73beaf75f7ac5dbcda3b_wirtual_44960203756_1647255903/360p30/index-dvr.m3u8\n"
  @expected_urls [
    "https://dgeft87wbj63p.cloudfront.net/73beaf75f7ac5dbcda3b_wirtual_44960203756_1647255903/chunked/index-dvr.m3u8",
    "https://dgeft87wbj63p.cloudfront.net/73beaf75f7ac5dbcda3b_wirtual_44960203756_1647255903/720p60/index-dvr.m3u8",
    "https://dgeft87wbj63p.cloudfront.net/73beaf75f7ac5dbcda3b_wirtual_44960203756_1647255903/720p30/index-dvr.m3u8",
    "https://dgeft87wbj63p.cloudfront.net/73beaf75f7ac5dbcda3b_wirtual_44960203756_1647255903/480p30/index-dvr.m3u8",
    "https://dgeft87wbj63p.cloudfront.net/73beaf75f7ac5dbcda3b_wirtual_44960203756_1647255903/360p30/index-dvr.m3u8"
  ]

  doctest M3U8

  test "module exists" do
    assert is_list(M3U8.module_info())
  end

  test "playlist can be parsed" do
    out = M3U8.new(@m3u8_body)

    assert URI.to_string(out.base) ==
             "https://dgeft87wbj63p.cloudfront.net/73beaf75f7ac5dbcda3b_wirtual_44960203756_1647255903"

    assert out.qualities == ["chunked", "720p60", "720p30", "480p30", "360p30"]
    assert out.filename == "index-dvr.m3u8"
  end

  test "URL building works as expected" do
    urls =
      M3U8.new(@m3u8_body)
      |> M3U8.build_urls()

    assert urls == @expected_urls
  end

  test "URL with multiple parts is parsed correctly" do
    out =
      M3U8.new(
        "https://dgeft87wbj63p.cloudfront.net/73beaf75f7ac5dbcda3b_wirtual/44960203756_1647255903/720p60/index-dvr.m3u8"
      )

    assert URI.to_string(out.base) ==
             "https://dgeft87wbj63p.cloudfront.net/73beaf75f7ac5dbcda3b_wirtual/44960203756_1647255903"

    assert out.qualities == ["chunked", "720p60"]
    assert out.filename == "index-dvr.m3u8"

    urls = M3U8.build_urls(out)

    assert urls == [
             "https://dgeft87wbj63p.cloudfront.net/73beaf75f7ac5dbcda3b_wirtual/44960203756_1647255903/chunked/index-dvr.m3u8",
             "https://dgeft87wbj63p.cloudfront.net/73beaf75f7ac5dbcda3b_wirtual/44960203756_1647255903/720p60/index-dvr.m3u8"
           ]
  end
end
