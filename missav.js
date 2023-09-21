/**
 * Missav plugin for Deup
 *
 * @class Missav
 * @extends {Deup}
 * @author ZiHang Gao
 * @see https://missav.com
 */
class Missav extends Deup {
  /**
   * Define the basic configuration of the missav plugin
   *
   * @type {{name: string, logo: string, pageSize: number}}
   */
  config = {
    name: 'Miss AV',
    logo: 'https://missav.com/img/favicon.png',
    layout: 'cover',
    pageSize: 12, // 每页显示的数量
  };

  check = () => true;

  /**
   * Get the video information of the specified id
   *
   * @param object
   * @returns {Promise<{headers: {Referer: string, "User-Agent": string}, name: *, id: string, type: string, url: string}>}
   */
  async get(object) {
    const url = `https://missav.com/cn/${object.id}`;
    const $ = $cheerio.load((await $axios.get(url)).data);

    // Get the video url
    const data = $.html().match(/eval\((?<data>(.*?))\)\n/);
    const { groups } = eval(`var data = ${data?.groups?.data}; data;`).match(
      /;source1280='(?<url>(.*?))';/,
    );

    return {
      id: object.id,
      name: $('div.mt-4 > h1.text-base').text(),
      cover: object.cover,
      url: groups.url,
      type: 'video',
      headers: {
        Referer: url,
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
  async list(object = null, offset = 0, limit = 20) {
    const page = Math.floor(offset / limit) + 1;
    const response = await $axios.get(`https://missav.com/cn/new?page=${page}`);
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
    const response = await $axios.get(
      `https://missav.com/cn/search/${keyword}?page=${page}`,
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

    return $('div.grid.grid-cols-2.gap-5')
      .first()
      .children('div')
      .map((i, el) => {
        const $a = $(el).find('div.relative').find('a').first();
        const $image = $a.find('img');
        const cover = $image.attr('data-src').replace('thumbnail', 'normal');
        const name = new URL($a.attr('href') || '').pathname.split('/').pop();

        return {
          id: name,
          name: `${name.toUpperCase()} ${$image.attr('alt')}`,
          thumbnail: cover,
          cover: cover,
          poster: cover,
          type: 'video',
        };
      })
      .get();
  }
}

Deup.execute(new Missav());
