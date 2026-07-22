/// 相机传输模式枚举
/// 目前只实现 experimentalNikon；后续 Sony/Canon/Fujifilm 留扩展点
enum CameraTransportMode {
  experimentalNikon;

  /// 显示标题
  String get title => 'Nikon Wi-Fi';

  /// 显示详情
  String get detail => '使用尼康相机 Wi-Fi 地址 192.168.1.1:15740 建立连接。';

  /// 默认主机名
  String? get defaultHost => '192.168.1.1';

  /// 默认端口 (CIPA PTP/IP 标准)
  int get defaultPort => 15740;
}
