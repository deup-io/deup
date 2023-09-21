/**
 * 91porn plugin for Deup
 *
 * @class Porn91
 * @extends {Deup}
 * @author ZiHang Gao
 * @see https://www.91porn.com
 */
class Porn91 extends Deup {
  /**
   * Define the basic configuration of the 91porn plugin
   *
   * @type {{name: string, logo: string, pageSize: number}}
   */
  config = {
    name: '91 Porn',
    logo: 'https://s2.loli.net/2023/09/09/T3MHtsGzk26Lyfi.jpg',
    layout: 'cover',
    pageSize: 24, // 每页显示的数量
  };

  /**
   * Define inputs
   *
   * @type {{cookie: {label: string, placeholder: string, required: boolean}}}
   */
  inputs = {
    category: {
      label: '类别',
      required: false,
      placeholder: '列表显示的类别, hot/new',
    },
    cookie: {
      label: 'Cookie',
      required: false,
      placeholder: '自定义请求 Cookie',
    },
  };

  check = () => true;

  /**
   * Get the video information of the specified id
   *
   * @param object
   * @returns {Promise<{headers: {Referer: string, "User-Agent": string}, name: *, id: string, type: string, url: string}>}
   */
  async get(object) {
    const response = await $axios.get(object.id);

    // Get the video url
    const data = response.data.match(
      /document.write\(strencode2\("(?<data>(.*?))"\)\);/,
    );
    const { groups } = strencode2(data?.groups?.data).match(
      /<source src='(?<url>(.*?))' type='application\/x-mpegURL'>/,
    );

    return {
      id: object.id,
      name: object.name,
      cover: object.cover,
      url: groups.url,
      type: 'video',
      headers: {
        Referer: 'https://www.91porn.com/',
        Cookie: (await $storage.inputs).cookie,
        'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.88 Safari/537.36',
      },
    };
  }

  /**
   * Get the video list
   *
   * @param object
   * @param offset
   * @param limit
   * @returns {Promise<*>}
   */
  async list(object = null, offset = 0, limit = 24) {
    const page = Math.floor(offset / limit) + 1;

    // Get the category
    const category = ((await $storage.inputs).category || 'hot')
      .toLowerCase()
      .trim();

    const cookie = (await $storage.inputs).cookie;
    const url = `https://www.91porn.com/v.php?category=${category}&viewtype=basic&page=${page}`;
    const response = await $axios.get(url, {
      headers: {
        Cookie: cookie ? cookie : 'language=cn_CN',
      },
    });
    return this.parseVideoList(response.data);
  }

  /**
   * Get the video list by keyword
   *
   * @param object
   * @param keyword
   * @param offset
   * @param limit
   * @returns {Promise<*>}
   */
  async search(object, keyword, offset, limit) {
    const page = Math.floor(offset / limit) + 1;
    const cookie = (await $storage.inputs).cookie;
    const response = await $axios.get(
      `https://www.91porn.com/search_result.php?search_id=${keyword}&search_type=search_videos&page${page}`,
      {
        headers: {
          Cookie: cookie ? cookie : 'language=cn_CN',
        },
      },
    );

    // Error handling
    const $ = $cheerio.load(response.data);
    const $errorbox = $('div.errorbox');
    if ($errorbox.length > 0) {
      $alert($errorbox.text().trim());
      return [];
    }

    // Check if the user is logged in
    if ($('#login').length > 0) {
      $alert('未登录或 Cookie 失效，请重新登录');
      return [];
    }

    return this.parseVideoList(response.data);
  }

  /**
   * Parse the video html to get the video list
   *
   * @param data
   * @returns {*}
   */
  parseVideoList(data) {
    const $ = $cheerio.load(data);

    return $('#wrapper div.col-sm-12 div.row')
      .children('div')
      .map((i, el) => {
        const $a = $(el).find('div.videos-text-align').find('a').first();
        const $image = $(el)
          .find('div.thumb-overlay img.img-responsive')
          .first();
        const cover = $image.attr('src');
        const name = $(el).find('span.video-title').text().trim();

        return {
          id: $a.attr('href'),
          name: name,
          thumbnail: cover,
          cover: cover,
          poster: cover,
          type: 'video',
        };
      })
      .get();
  }
}

Deup.execute(new Porn91());

// see: https://www.91porn.com/js/m2.js
var encode_version = 'jsjiami.com.v5',
  eexda = '__0x9ff10',
  __0x9ff10 = [
    'w7FkXcKcwqs=',
    'VMKAw7Fhw6Q=',
    'w5nDlTY7w4A=',
    'wqQ5w4pKwok=',
    'dcKnwrTCtBg=',
    'w45yHsO3woU=',
    '54u75py15Y6177y0PcKk5L665a2j5pyo5b2156i677yg6L+S6K2D5pW65o6D5oqo5Lmn55i/5bSn5L21',
    'RsOzwq5fGQ==',
    'woHDiMK0w7HDiA==',
    '54uS5pyR5Y6r7764wr3DleS+ouWtgeaesOW/sOeooe+/nei/ruitteaWsuaOmeaKiuS4o+eateW2i+S8ng==',
    'bMOKwqA=',
    'V8Knwpo=',
    'csOIwoVsG1rCiUFU',
    '5YmL6ZiV54qm5pyC5Y2i776Lw4LCrOS+muWssOacteW8lOeqtg==',
    'w75fMA==',
    'YsOUwpU=',
    'wqzDtsKcw5fDvQ==',
    'wqNMOGfCn13DmjTClg==',
    'wozDisOlHHI=',
    'GiPConNN',
    'XcKzwrDCvSg=',
    'U8K+wofCmcO6',
  ];
(function (_0x1f2e93, _0x60307d) {
  var _0x1f9a0b = function (_0x35f19b) {
    while (--_0x35f19b) {
      _0x1f2e93['push'](_0x1f2e93['shift']());
    }
  };
  _0x1f9a0b(++_0x60307d);
})(__0x9ff10, 0x152);
var _0x43d9 = function (_0x13228a, _0x2ce452) {
  _0x13228a = _0x13228a - 0x0;
  var _0x424175 = __0x9ff10[_0x13228a];
  if (_0x43d9['initialized'] === undefined) {
    (function () {
      var _0x270d2c =
        typeof window !== 'undefined'
          ? window
          : typeof process === 'object' &&
            typeof require === 'function' &&
            typeof global === 'object'
          ? global
          : this;
      var _0x58680b =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=';
      _0x270d2c['atob'] ||
        (_0x270d2c['atob'] = function (_0x5536e1) {
          var _0x15e9d3 = String(_0x5536e1)['replace'](/=+$/, '');
          for (
            var _0x4e6299 = 0x0,
              _0x3590d2,
              _0x48c90b,
              _0x557f6a = 0x0,
              _0x2b086d = '';
            (_0x48c90b = _0x15e9d3['charAt'](_0x557f6a++));
            ~_0x48c90b &&
            ((_0x3590d2 =
              _0x4e6299 % 0x4 ? _0x3590d2 * 0x40 + _0x48c90b : _0x48c90b),
            _0x4e6299++ % 0x4)
              ? (_0x2b086d += String['fromCharCode'](
                  0xff & (_0x3590d2 >> ((-0x2 * _0x4e6299) & 0x6)),
                ))
              : 0x0
          ) {
            _0x48c90b = _0x58680b['indexOf'](_0x48c90b);
          }
          return _0x2b086d;
        });
    })();
    var _0x4a2d38 = function (_0x1f120d, _0x1d6e11) {
      var _0x4c36f9 = [],
        _0x1c4b64 = 0x0,
        _0x18ce5c,
        _0x39c9fa = '',
        _0x6d02b2 = '';
      _0x1f120d = atob(_0x1f120d);
      for (
        var _0x13b203 = 0x0, _0x24d88b = _0x1f120d['length'];
        _0x13b203 < _0x24d88b;
        _0x13b203++
      ) {
        _0x6d02b2 +=
          '%' +
          ('00' + _0x1f120d['charCodeAt'](_0x13b203)['toString'](0x10))[
            'slice'
          ](-0x2);
      }
      _0x1f120d = decodeURIComponent(_0x6d02b2);
      for (var _0x1f76f3 = 0x0; _0x1f76f3 < 0x100; _0x1f76f3++) {
        _0x4c36f9[_0x1f76f3] = _0x1f76f3;
      }
      for (_0x1f76f3 = 0x0; _0x1f76f3 < 0x100; _0x1f76f3++) {
        _0x1c4b64 =
          (_0x1c4b64 +
            _0x4c36f9[_0x1f76f3] +
            _0x1d6e11['charCodeAt'](_0x1f76f3 % _0x1d6e11['length'])) %
          0x100;
        _0x18ce5c = _0x4c36f9[_0x1f76f3];
        _0x4c36f9[_0x1f76f3] = _0x4c36f9[_0x1c4b64];
        _0x4c36f9[_0x1c4b64] = _0x18ce5c;
      }
      _0x1f76f3 = 0x0;
      _0x1c4b64 = 0x0;
      for (var _0x2b6a92 = 0x0; _0x2b6a92 < _0x1f120d['length']; _0x2b6a92++) {
        _0x1f76f3 = (_0x1f76f3 + 0x1) % 0x100;
        _0x1c4b64 = (_0x1c4b64 + _0x4c36f9[_0x1f76f3]) % 0x100;
        _0x18ce5c = _0x4c36f9[_0x1f76f3];
        _0x4c36f9[_0x1f76f3] = _0x4c36f9[_0x1c4b64];
        _0x4c36f9[_0x1c4b64] = _0x18ce5c;
        _0x39c9fa += String['fromCharCode'](
          _0x1f120d['charCodeAt'](_0x2b6a92) ^
            _0x4c36f9[(_0x4c36f9[_0x1f76f3] + _0x4c36f9[_0x1c4b64]) % 0x100],
        );
      }
      return _0x39c9fa;
    };
    _0x43d9['rc4'] = _0x4a2d38;
    _0x43d9['data'] = {};
    _0x43d9['initialized'] = !![];
  }
  var _0x302f80 = _0x43d9['data'][_0x13228a];
  if (_0x302f80 === undefined) {
    if (_0x43d9['once'] === undefined) {
      _0x43d9['once'] = !![];
    }
    _0x424175 = _0x43d9['rc4'](_0x424175, _0x2ce452);
    _0x43d9['data'][_0x13228a] = _0x424175;
  } else {
    _0x424175 = _0x302f80;
  }
  return _0x424175;
};
function strencode2(_0x4f0d7a) {
  var _0x4c6de5 = {
    Anfny: function _0x4f6a21(_0x51d0ce, _0x5a5f36) {
      return _0x51d0ce(_0x5a5f36);
    },
  };
  return _0x4c6de5[_0x43d9('0x0', 'fo#E')](unescape, _0x4f0d7a);
}
(function (_0x17883e, _0x4a42d3, _0xe4080c) {
  var _0x301ffc = {
    lPNHL: function _0x1c947e(_0x4d57b6, _0x51f6a5) {
      return _0x4d57b6 !== _0x51f6a5;
    },
    EPdUx: function _0x55f4cc(_0x34b7bc, _0x9f930c) {
      return _0x34b7bc === _0x9f930c;
    },
    kjFfJ: 'jsjiami.com.v5',
    DFsBH: function _0x5f08ac(_0x1e6fa1, _0x4c0aef) {
      return _0x1e6fa1 + _0x4c0aef;
    },
    akiuH: _0x43d9('0x1', 'KYjt'),
    VtfeI: function _0x4f3b7b(_0x572344, _0x5f0cde) {
      return _0x572344(_0x5f0cde);
    },
    Deqmq: _0x43d9('0x2', 'oYRG'),
    oKQDc: _0x43d9('0x3', 'i^vo'),
    UMyIE: _0x43d9('0x4', 'oYRG'),
    lRwKx: function _0x5b71b4(_0x163a75, _0x4d3998) {
      return _0x163a75 === _0x4d3998;
    },
    TOBCR: function _0x314af8(_0x3e6efe, _0x275766) {
      return _0x3e6efe + _0x275766;
    },
    AUOVd: _0x43d9('0x5', 'lALy'),
  };
  _0xe4080c = 'al';
  try {
    if ('EqF' !== _0x43d9('0x6', 'xSW]')) {
      _0xe4080c += _0x43d9('0x7', 'oYRG');
      _0x4a42d3 = encode_version;
      if (
        !(
          _0x301ffc[_0x43d9('0x8', 'fo#E')](
            typeof _0x4a42d3,
            _0x43d9('0x9', '*oMH'),
          ) &&
          _0x301ffc[_0x43d9('0xa', 'ov6D')](
            _0x4a42d3,
            _0x301ffc[_0x43d9('0xb', '3k]D')],
          )
        )
      ) {
        _0x17883e[_0xe4080c](
          _0x301ffc[_0x43d9('0xc', '@&#[')](
            '删除',
            _0x301ffc[_0x43d9('0xd', 'i^vo')],
          ),
        );
      }
    } else {
      return _0x301ffc[_0x43d9('0xe', 'rvlM')](unescape, input);
    }
  } catch (_0x23e6c5) {
    if ('svo' !== _0x301ffc[_0x43d9('0xf', 'TpCD')]) {
      _0x17883e[_0xe4080c]('删除版本号，js会定期弹窗');
    } else {
      _0xe4080c = 'al';
      try {
        _0xe4080c += _0x301ffc[_0x43d9('0x10', 'doK*')];
        _0x4a42d3 = encode_version;
        if (
          !(
            _0x301ffc[_0x43d9('0x11', 'ZRZ4')](
              typeof _0x4a42d3,
              _0x301ffc['UMyIE'],
            ) &&
            _0x301ffc[_0x43d9('0x12', '@&#[')](_0x4a42d3, _0x301ffc['kjFfJ'])
          )
        ) {
          _0x17883e[_0xe4080c](
            _0x301ffc[_0x43d9('0x13', 'KYjt')]('删除', _0x43d9('0x14', 'xSW]')),
          );
        }
      } catch (_0x4202f6) {
        _0x17883e[_0xe4080c](_0x301ffc[_0x43d9('0x15', 'oYRG')]);
      }
    }
  }
})(window);
encode_version = 'jsjiami.com.v5';
