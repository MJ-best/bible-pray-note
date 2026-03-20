abstract final class RoutePaths {
  static const root = '/';
  static const login = '/login';
  static const dashboard = '/dashboard';
  static const workspaces = '/workspaces';
  static const projects = '/projects';
  static const settings = '/settings';

  static String project(String projectId) => '$projects/$projectId';

  static String artifact(String projectId, String artifactId) {
    return '${project(projectId)}/artifacts/$artifactId';
  }
}
