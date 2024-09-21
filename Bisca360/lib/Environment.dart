class Environment {
  static load(String envName) {
    if (envName == 'dev') {
      return '.env.dev';
    } else if (envName == 'ist') {
      return '.env.ist';
    } else if (envName == 'prd') {
      return '.env.prd';
    } else {
      return '.env.prd';
    }
  }
}
