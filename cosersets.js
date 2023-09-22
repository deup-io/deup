/**
 * Cosersets plugin for Deup
 *
 * @class Cosersets
 * @extends {Deup}
 * @author ZiHang Gao
 * @see https://www.cosersets.com
 */
class Cosersets extends Deup {
  /**
   * Define the basic configuration of the cosersets plugin
   *
   * @type {{name: string, logo: string}}
   */
  config = {
    name: 'Cosersets',
    logo: 'https://www.cosersets.com/favicon.ico',
  };

  check = () => true;
  search = (object, keyword, offset, limit) => $alert('暂不支持搜索');

  /**
   * Get the object information of the specified id
   *
   * @param object
   * @returns {Promise<any>}
   */
  async get(object) {
    return object;
  }

  /**
   * Get object list
   *
   * @param object
   * @param offset
   * @param limit
   * @returns {Promise<*>}
   */
  async list(object, offset, limit) {
    if (offset !== 0) return [];
    const path = object ? (object.extra ? object.extra.path || '/' : '/') : '/';
    const response = await $axios.get(
      `https://www.cosersets.com/api/list/1?path=${path}`,
    );

    const { code, data } = response.data;
    const isFolder = (type) => type.toLowerCase() === 'folder';
    if (code === 0 && data.files) {
      return data.files.map((file) => ({
        id: `${path}${file.name}`,
        name: file.name,
        type: file.type.toLowerCase(),
        modified: new Date(
          Date.parse(file.time.replace(' ', 'T')),
        ).toISOString(),
        thumbnail: isFolder(file.type) ? '' : file.url,
        url: file.url,
        extra: { path: `${path}${file.name}/` },
      }));
    }
  }
}

// Register
Deup.execute(new Cosersets());
