import native from 'libdaisy_native.so'
import { LoginInfo } from 'libdaisy_native.so'
import { hilog } from '@kit.PerformanceAnalysisKit';

@ObservedV2
export class LoginListen {
  @Trace loginState: LoginInfo = {
    status: -1, // -1 未登录 / -2 登录中 / 0 / 2
    message: '',
  }
}

class Context {

  async login() {
    loginListen.loginState = {
      status: -2,
      message: '',
    }
    let username = await native.loadProperty("username");
    let password = await native.loadProperty("password");
    hilog.warn(0, 'testTag', '%{public}s', 'logging');
    if (username.length > 0 && password.length > 0) {
      loginListen.loginState = await native.reLogin(username, password);
    } else {
      loginListen.loginState = {
        status: -1,
        message: '',
      }
    }
    hilog.warn(0, 'testTag', '%{public}s', 'logged');
  }
}

export let context = new Context()

export let loginListen = new LoginListen()
