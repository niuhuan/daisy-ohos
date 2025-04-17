import native from 'daisy_native'
import { LoginInfo } from 'daisy_native'
import { hilog } from '@kit.PerformanceAnalysisKit';

@ObservedV2
export class LoginListen {
  @Trace loginState: LoginInfo = {
    status: -1, // -1 未登录 / -2 登录中 / 0 登录成功 / 2 登录失败
    message: '',
  }
}

class Context {
  async reLogin() {
    loginListen.loginState = {
      status: -2,
      message: '',
    }
    loginListen.loginState = await native.reLogin();
  }

  async login(username: string, password: string) {
    loginListen.loginState = {
      status: -2,
      message: '',
    }
    hilog.warn(0, 'testTag', '%{public}s', 'logging');
    if (username.length > 0 && password.length > 0) {
      loginListen.loginState = await native.login(username, password);
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
