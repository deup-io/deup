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
   * @param id
   * @returns {Promise<{path: string, thumbnail: *, created: *, name, modified: *, type: string, isDirectory: boolean, url}>}
   */
  async get(id) {
    const clientId = (await $storage.inputs).clientId;

    const { data } = await $axios.get(
      `https://api.unsplash.com/photos/${id}/?client_id=${clientId}`,
    );

    return this.formatObject(data);
  }

  /**
   * Get image list
   *
   * @param path
   * @param offset
   * @param limit
   * @returns {Promise<{path: string, thumbnail: *, created: *, name: *, modified: *, type: string, isDirectory: boolean, url: *}[]>}
   */
  async list(path = '', offset = 0, limit = 20) {
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
   * @param path
   * @param keyword
   * @param offset
   * @param limit
   * @returns {Promise<{path: string, thumbnail: *, created: *, name: *, modified: *, type: string, isDirectory: boolean, url: *}[]>}
   */
  async search(path, keyword, offset, limit) {
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
   * @returns {{path: string, thumbnail: *, created: *, name, modified: *, type: string, isDirectory: boolean, url}}
   */
  formatObject(image) {
    return {
      name: image.id,
      type: 'image',
      path: '', // path is specified as an empty string, because by default / is prepended to the path
      isDirectory: false,
      thumbnail: image.urls.thumb,
      created: image.created_at,
      modified: image.updated_at,
      url: image.urls.regular,
    };
  }
}

Deup.execute(new Unsplash());
