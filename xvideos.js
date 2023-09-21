/**
 * Xvideos plugin for Deup
 *
 * @class Xvideos
 * @extends {Deup}
 * @author ZiHang Gao
 * @see https://www.xvideos.com
 */
class Xvideos extends Deup {
  /**
   * Define the basic configuration of the xvideos plugin
   *
   * @type {{name: string, logo: string, pageSize: number}}
   */
  config = {
    name: 'X Videos',
    logo: 'https://static-cdn77.xvideos-cdn.com/v3/img/skins/default/logo/xv.black.svg',
    layout: 'cover',
    timeout: 10000, // 超时时间
    pageSize: 27, // 每页显示的数量
    headers: {
      'User-Agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.88 Safari/537.36',
      'Accept-Encoding': 'gzip, deflate, br',
      'Accept-Language': 'zh-CN,zh;q=0.9,en-US;q=0.8,en;q=0.7',
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
    const response = await $axios.get(`https://www.xvideos.com${object.id}`);

    // Get the hls url
    const data = response.data.match(
      /html5player.setVideoHLS\('(?<url>(.*?))'\);/,
    );
    const hls = await $axios.get(data.groups.url);

    // Parse m3u8 to get the highest resolution m3u8 address
    const m3u8 = hls.data.split('\n').filter((v) => v.endsWith('.m3u8'));

    // Match 1080p 720p 480p 360p 250p
    const groups = {
      '1080p': m3u8.find((v) => v.includes('1080p')),
      '720p': m3u8.find((v) => v.includes('720p')),
      '480p': m3u8.find((v) => v.includes('480p')),
      '360p': m3u8.find((v) => v.includes('360p')),
      '250p': m3u8.find((v) => v.includes('250p')),
    };

    return {
      id: object.id,
      name: object.name,
      cover: object.cover,
      url: data.groups.url.replace(
        'hls.m3u8',
        groups['1080p'] ||
          groups['720p'] ||
          groups['480p'] ||
          groups['360p'] ||
          groups['250p'],
      ),
      type: 'video',
      headers: {
        ...{
          Referer: `https://www.xvideos.com${object.id}`,
        },
        ...this.config.headers,
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
  async list(object = null, offset = 0, limit = 27) {
    const page = Math.floor(offset / limit) + 1;
    const response = await $axios.get(`https://www.xvideos.com/new/${page}`, {
      headers: this.config.headers,
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
  async search(object = null, keyword = '', offset = 0, limit = 27) {
    const page = Math.floor(offset / limit);
    const response = await $axios.get(
      `https://www.xvideos.com/?k=${keyword}&p=${page}`,
      {
        headers: this.config.headers,
      },
    );
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

    return $('#content [id^=video]')
      .map((i, el) => {
        const $a = $(el).find('a').first();
        const $image = $a.find('img').first();
        const cover = $image.attr('data-src');
        const name = $(el).find('div.thumb-under p.title a').attr('title');

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

Deup.execute(new Xvideos());
