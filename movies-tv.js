/**
 * MoviesTv plugin for Deup
 *
 * @class MoviesTv
 * @extends {Deup}
 * @author ZiHang Gao
 */
class MoviesTv extends Deup {
  /**
   * Define the basic configuration
   *
   * @type {{layout: string, name: string, pageSize: number, timeout: number}}
   */
  config = {
    name: 'Movies & TV',
    layout: 'poster',
    timeout: 10000,
    pageSize: 50,
  };

  /**
   * Define inputs
   *
   * Types:
   * - 1: 电影
   * - 2: 电视剧
   * - 3: 综艺
   * - 4: 动漫
   * - 6: 动作
   * - 7: 喜剧
   * - 8: 爱情
   * - 9: 科幻
   * - 10: 恐怖
   * - 11: 剧情
   * - 12: 战争
   * - 13: 国产剧
   * - 14: 香港剧
   * - 15: 韩国剧
   * - 16: 欧美剧
   * - 20: 记录片
   * - 21: 台湾剧
   * - 22: 日本剧
   * - 23: 海外剧
   * - 24: 泰国剧
   * - 25: 大陆综艺
   * - 26: 港台综艺
   * - 27: 日韩综艺
   * - 28: 欧美综艺
   * - 29: 国产动漫
   * - 30: 日韩动漫
   * - 31: 欧美动漫
   * - 32: 港台动漫
   * - 33: 海外动漫
   * - 34: 伦理片
   * - 35: 电影解说
   * - 36: 体育
   * - 37: 足球
   * - 38: 篮球
   * - 39: 网球
   * - 40: 斯诺克
   *
   * @type {{type: {label: string, placeholder: string, required: boolean}}}
   */
  inputs = {
    type: {
      label: '类别',
      required: false,
      placeholder: '默认为全部类别, 详情请查看源码注释, eg: 1',
    },
  };

  /**
   * Check inputs
   *
   * @returns {Promise<boolean>}
   */
  async check() {
    try {
      return (await this.list()).length > 0;
    } catch (e) {
      $alert(e.message);
    }

    return false;
  }

  /**
   * Get the object information
   *
   * @param object
   * @returns {Promise<any>}
   */
  async get(object) {
    return object.extra ? { ...object, name: object.extra.name } : object;
  }

  /**
   * Get the video list
   *
   * @param object
   * @param offset
   * @param limit
   * @returns {Promise<*>}
   */
  async list(object = null, offset = 0, limit = 50) {
    const page = Math.floor(offset / limit) + 1;
    const type = (await $storage.inputs).type || '';
    let url = `https://cj.lziapi.com/api.php/provide/vod?ac=detail&pg=${page}&pagesize=${limit}`;

    // Filter by type
    if (type !== '') {
      const $ = $cheerio.load(
        (
          await $axios.get(
            `http://lzizy.net/index.php/vod/type/id/${type}/page/${page}.html`,
          )
        ).data,
      );
      const ids = $('ul.videoContent')
        .children()
        .map((index, element) => {
          const url = $(element).find('a.videoName').attr('href');
          return url?.match(/\/(?<id>\d+)\.html/)?.groups?.id;
        })
        .get()
        .join(',');

      if (ids === '') {
        $alert('未发现该类别的视频, 请查看源码注释获取类别编号');
        return [];
      }
      url = `https://cj.lziapi.com/api.php/provide/vod?ac=detail&ids=${ids}&pagesize=${limit}`;
    }

    try {
      const response = await $axios.get(url);
      return this.formatVideoList(response.data);
    } catch (e) {
      $alert(e.message);
    }

    return [];
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
    try {
      const page = Math.floor(offset / limit) + 1;
      const response = await $axios.get(
        `https://cj.lziapi.com/api.php/provide/vod?ac=detail&wd=${keyword}&pg=${page}&pagesize=${limit}`,
      );

      return this.formatVideoList(response.data);
    } catch (e) {
      $alert(e.message);
    }

    return [];
  }

  /**
   * Format object list
   *
   * @param data
   * @returns {*}
   */
  formatVideoList(data) {
    return data.list.map((video) => {
      const playUrls =
        video.vod_play_note === ''
          ? video.vod_play_url.split('#')
          : video.vod_play_url.split(video.vod_play_note)[1].split('#');

      return {
        id: `${video.vod_id}#1`,
        name: video.vod_name,
        type: 'video',
        remark: video.vod_name,
        thumbnail: video.vod_pic,
        poster: video.vod_pic,
        modified: new Date(
          Date.parse(video.vod_time.replace(' ', 'T')),
        ).toISOString(),
        url: playUrls[0].split('$')[1],
        extra: {
          name:
            playUrls.length > 1 ? playUrls[0].split('$')[0] : video.vod_name,
        },
        related: playUrls.map((value, key) => {
          const [name, url] = value.split('$');
          return {
            id: `${video.vod_id}#${key + 1}`,
            name: playUrls.length > 1 ? name : video.vod_name,
            url,
            type: 'video',
            thumbnail: video.vod_pic,
          };
        }),
      };
    });
  }
}

Deup.execute(new MoviesTv());
