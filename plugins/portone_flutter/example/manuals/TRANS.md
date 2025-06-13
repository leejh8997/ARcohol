# 실시간 계좌이체 설정하기

## Android - 웹 표준 이니시스 또는 나이스 정보통신
Android에서 `웹 표준 이니시스(이하 이니시스)` 또는 `나이스` `실시간 계좌이체`를 연동하는 경우 별도 설정이 요구됩니다. 이니시스는 결제완료 후 콜백이 실행되지 않고, 나이스는 결제인증 후 결제완료 처리가 되지 않기 때문입니다. 이는 이니시스와 나이스 결제모듈 자체 문제입니다. 포트원 V1 플러터 모듈은 이에 대응하기 위한 안내를 제공하고 있습니다.

### 실시간 계좌이체 결제처리 원리
먼저 뱅크페이 앱에서 귀하의 앱으로 복귀할때를 트리거해야합니다. 포트원 V1 플러터 모듈은 트리거 된 순간 이니시스의 경우 콜백을 실행시키고, 나이스의 경우 나이스로 결제정보가 담긴 POST 요청을 보내야 합니다. Java는 들어오는(`incoming`) 앱 링크를 트리거 하기 위해 `deep linking` 기능을 제공합니다.

### Intent Filter 추가하고 launchMode 설정하기
deep linking 기능을 활성화하기 위해 `Intent Filter`를 추가하고 `MainActivity`의 `launchMode`를 아래와 같이 `singleTask`로 설정해야 합니다. 자세한 내용은 [Create Deep Links to App Content](https://developer.android.com/training/app-links/deep-linking)를 참고하세요.

```xml
...
<!-- [프로젝트 이름]/android/app/src/main/AndroidManifest.xml -->
<!-- MainActivity의 launchMode를 singleTask로 설정 -->
<activity
  android:name=".MainActivity"
  android:launchMode="singleTask"
>
  ...
  <!-- Intent Filter 추가 -->
  <intent-filter>
    <action android:name="android.intent.action.VIEW"/>
    <category android:name="android.intent.category.DEFAULT"/>
    <category android:name="android.intent.category.BROWSABLE"/>
    <data android:scheme="앱 스킴 값 EX. example" />
  </intent-filter>
</activity>
...
```