/**
 * Unsplash plugin for Deup
 *
 * @class Unsplash
 * @extends {Deup}
 * @author ZiHang Gao
 * @see https://unsplash.com/documentation
 */
class Unsplash extends Deup {
  /**
   * Define the basic configuration of the unsplash plugin
   *
   * @type {{layout: string, name: string, logo: string}}
   */
  config = {
    name: 'Unsplash',
    layout: 'image',
    logo: 'https://s2.loli.net/2023/08/29/qd3CeOP8Kpcikao.png',
  };

  /**
   * Define inputs
   *
   * @type {{clientId: {label: string, placeholder: string, required: boolean}}}
   */
  inputs = {
    clientId: {
      label: 'Access Key',
      required: true,
      placeholder: 'Unsplash Access Key',
    },
  };

  /**
   * Check inputs
   *
   * @returns {Promise<boolean>}
   */
  async check() {
    return (await this.list()).length > 0;
  }

  /**
   * Get the image information of the specified id
   *
   * @param object
   * @returns {Promise<{thumbnail: *, created: *, name, modified: *, type: string, url}>}
   */
  async get(object) {
    const clientId = (await $storage.inputs).clientId;

    const { data } = await $axios.get(
      `https://api.unsplash.com/photos/${object.id}/?client_id=${clientId}`,
    );

    return this.formatObject(data);
  }

  /**
   * Get image list
   *
   * @param object
   * @param offset
   * @param limit
   * @returns {Promise<{thumbnail: *, created: *, name: *, modified: *, type: string, url: *}[]>}
   */
  async list(object = null, offset = 0, limit = 20) {
    const page = Math.floor(offset / limit) + 1;
    const clientId = (await $storage.inputs).clientId;

    const { data } = await $axios.get(
      `https://api.unsplash.com/photos/?client_id=${clientId}&page=${page}&per_page=${limit}`,
    );

    return data.map((image) => this.formatObject(image));
  }

  /**
   * Search image
   *
   * @param object
   * @param keyword
   * @param offset
   * @param limit
   * @returns {Promise<{thumbnail: *, created: *, name: *, modified: *, type: string, url: *}[]>}
   */
  async search(object, keyword, offset, limit) {
    const page = Math.floor(offset / limit) + 1;
    const clientId = (await $storage.inputs).clientId;

    const { data } = await $axios.get(
      `https://api.unsplash.com/search/photos/?client_id=${clientId}&query=${keyword}&page=${page}&per_page=${limit}`,
    );

    return data.results.map((image) => this.formatObject(image));
  }

  /**
   * Format image information
   *
   * @param image
   * @returns {{thumbnail: *, created: *, name, modified: *, type: string, url}}
   */
  formatObject(image) {
    return {
      id: image.id,
      type: 'image',
      thumbnail: image.urls.thumb,
      created: image.created_at,
      modified: image.updated_at,
      url: image.urls.regular,
    };
  }
}

Deup.execute(new Unsplash());
