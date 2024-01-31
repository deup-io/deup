/**
 * IPTV plugin for Deup
 *
 * @class IPTV
 * @extends {Deup}
 * @author ZiHang Gao
 */
class IPTV extends Deup {
  /**
   * Define the basic configuration of the IPTV plugin
   *
   * @type {{layout: string, name: string}}
   */
  config = {
    name: 'IPTV - CCTV Live',
    layout: 'poster',
  };

  /**
   * BaseUrl
   *
   * @type {string}
   * @private
   */
  _baseUrl = 'https://cntv.lat/tv?auth=202311030915';

  /**
   * Channel list
   *
   * @private
   * @type {{name: string, type: string, poster: string, url: string}[]}
   * @memberof IPTV
   * @see https://github.com/fanmingming/live
   */
  _channels = [
    {
      name: 'CCTV-1 综合',
      poster: 'https://s2.loli.net/2023/08/30/VhHLMk98rm2gYvu.png',
      url: `${this._baseUrl}&id=cctv1`,
    },
    {
      name: 'CCTV-2 财经',
      poster: 'https://s2.loli.net/2023/08/30/2YqziAxuJmWZgEl.png',
      url: `${this._baseUrl}&id=cctv2`,
    },
    {
      name: 'CCTV-3 综艺',
      poster: 'https://s2.loli.net/2023/08/30/gyWSnKhzotF1O7r.png',
      url: `${this._baseUrl}&id=cctv3`,
    },
    {
      name: 'CCTV-4 中文国际',
      poster: 'https://s2.loli.net/2023/08/30/kWI5xNPCBpdqnY6.png',
      url: `${this._baseUrl}&id=cctv4`,
    },
    {
      name: 'CCTV-5 体育',
      poster: 'https://s2.loli.net/2023/08/30/I5MqfnkLduwKjaQ.png',
      url: `${this._baseUrl}&id=cctv5`,
    },
    {
      name: 'CCTV-5+ 体育赛事',
      poster: 'https://s2.loli.net/2023/08/30/Q9jdSYAGy5kFNm3.png',
      url: `${this._baseUrl}&id=cctv5p`,
    },
    {
      name: 'CCTV-6 电影',
      poster: 'https://s2.loli.net/2023/08/30/wX5bjlpy6ZquCVL.png',
      url: `${this._baseUrl}&id=cctv6`,
    },
    {
      name: 'CCTV-7 国防军事',
      poster: 'https://s2.loli.net/2023/08/30/grtoQpCzY4E37BN.png',
      url: `${this._baseUrl}&id=cctv7`,
    },
    {
      name: 'CCTV-8 电视剧',
      poster: 'https://s2.loli.net/2023/08/30/2iu4ADUBPOv6snW.png',
      url: `${this._baseUrl}&id=cctv8`,
    },
    {
      name: 'CCTV-9 纪录',
      poster: 'https://s2.loli.net/2023/08/30/IH4fAMm78dPVBJE.png',
      url: `${this._baseUrl}&id=cctv9`,
    },
    {
      name: 'CCTV-10 科教',
      poster: 'https://s2.loli.net/2023/08/30/AHaGdMOt3ZWVpgQ.png',
      url: `${this._baseUrl}&id=cctv10`,
    },
    {
      name: 'CCTV-11 戏曲',
      poster: 'https://s2.loli.net/2023/08/30/a8XNDkfgPUvruO3.png',
      url: `${this._baseUrl}&id=cctv11`,
    },
    {
      name: 'CCTV-12 社会与法',
      poster: 'https://s2.loli.net/2023/08/30/adFC3INOh9mAw1X.png',
      url: `${this._baseUrl}&id=cctv12`,
    },
    {
      name: 'CCTV-13 新闻',
      poster: 'https://s2.loli.net/2023/08/30/FKgm5LoV4hESc2J.png',
      url: `${this._baseUrl}&id=cctv13`,
    },
    {
      name: 'CCTV-14 少儿',
      poster: 'https://s2.loli.net/2023/08/30/ThYMDHq9S5L1JNP.png',
      url: `${this._baseUrl}&id=cctv14`,
    },
    {
      name: 'CCTV-15 音乐',
      poster: 'https://s2.loli.net/2023/08/30/HIrOpoen2D3zlda.png',
      url: `${this._baseUrl}&id=cctv15`,
    },
    {
      name: 'CCTV-16 奥林匹克',
      poster: 'https://s2.loli.net/2023/08/30/U2B4aXSHverE6do.png',
      url: `${this._baseUrl}&id=cctv16`,
    },
    {
      name: 'CCTV-17 农业农村',
      poster: 'https://s2.loli.net/2023/08/30/UefnGBCLMJXt3hQ.png',
      url: `${this._baseUrl}&id=cctv17`,
    },
  ].map((channel) => ({
    ...channel,
    ...{ id: channel.name, isLive: true, type: 'video' },
  }));

  // Android quickjs fixed, not available `get = (id) => []`
  async get(object) {
    return _.find(this._channels, (channel) => channel.id === object.id);
  }

  check = () => true;
  list = (object, offset, limit) => (offset === 0 ? this._channels : []);
  search = (object, keyword, offset, limit) =>
    offset === 0
      ? _.filter(this._channels, (channel) => channel.name.includes(keyword))
      : [];
}

Deup.execute(new IPTV());
