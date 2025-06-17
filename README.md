
# 🍹 Flutter 기반 칵테일 레시피/커머스 앱

나만의 바(MyBar) 기능과 AR 시연, 실시간 리뷰 및 주문 관리까지 지원하는 **올인원 칵테일 플랫폼 앱**입니다.  
사용자는 마이바 재료를 기반으로 추천 레시피를 받고, 제품을 구매하거나 리뷰를 작성할 수 있으며, 관리자 없이도 앱 내에서 다양한 유저 액션을 처리할 수 있습니다.

---

## 📆 개발 기간

- 2025년 6월 1일 ~ (진행 중)
- Firestore 구조 설계, UI 개발, 기능 구현 순으로 진행

---

## 👨‍👩‍👦‍👦 팀원 구성

| 이름   | GitHub 프로필 |
|--------|----------------|
| 이재형 | https://github.com/leejh8997 |

---

## 💻 사용 언어 및 기술 스택

### 📱 Mobile (Flutter)
![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Android Studio](https://img.shields.io/badge/Android Studio-3DDC84?style=for-the-badge&logo=androidstudio&logoColor=white)

### ☁️ Backend (Firebase)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![Firestore](https://img.shields.io/badge/Firestore-FFA000?style=for-the-badge&logo=firebase&logoColor=white)
![Firebase Auth](https://img.shields.io/badge/Firebase Auth-FF6D00?style=for-the-badge&logo=firebase&logoColor=white)
![Firebase Storage](https://img.shields.io/badge/Firebase Storage-019CFE?style=for-the-badge&logo=google-cloud&logoColor=white)

---

## 📄 주요 기능 및 페이지

### 🔐 로그인/회원가입
- Firebase Auth 기반 이메일 로그인 구현
- 로그인 시 Firestore에서 사용자 정보 동기화
- Drawer 상단에 유저 이름 및 정보 표시

---

### 🏠 홈 페이지
- 배너: 랜덤 레시피 3개 슬라이드 표시
- 추천 레시피: 마이바 재료 기반 추천 (최대 5개 + more 버튼)
- 인기 레시피: 좋아요 수 기준 내림차순 정렬
- 판매 상품: Firestore product 컬렉션에서 무작위 5개 로드

---

### 🧾 상품 상세 페이지
- 상품 정보, 이미지, 가격, 설명, 사이즈 등 상세 출력
- 하단 탭: 상품정보 / 문의 (→ 리뷰로 기능 전환됨)
- 리뷰: 구매자만 작성 가능, 수정/삭제 기능 지원
- 장바구니 및 바로 구매 버튼 포함

---

### 🛒 장바구니
- Firestore 사용자 cartitem 기반 실시간 렌더링
- 수량 증감 및 선택/전체선택 기능
- 상품 클릭 시 상세페이지 이동

---

### 💳 결제 페이지
- 배송지 정보 (이름, 연락처, 주소) 자동 불러오기
- 배송 메모 선택/직접 입력 가능
- 총 금액 강조 박스 출력
- 결제 완료 시 Firestore에 order 문서 생성

---

### 📦 주문 내역
- 주문번호, 결제일, 상태, 제품별 카드형 정보 출력
- 배송 상태별 필터링 처리
- 리뷰 작성 버튼(배송 완료 상태일 때만 표시)

---

### 🔁 주문 취소/교환
- 상태가 'preparing'일 경우만 가능
- 사유 선택 또는 직접 입력 후 처리
- Firestore order 문서 내 status / reason 필드 업데이트
- 취소/교환 주문은 목록에서 자동 제외됨

---

### 🧪 AR 기능 (테스트용)
- 버튼 클릭 시 AR 안내 페이지로 이동
- ARCore 기반 비율 시연 기능 예정

---

## ✍ 프로젝트 후기

- Firebase Firestore 구조 설계를 직접 하며 **NoSQL 기반 앱 설계 경험**을 쌓을 수 있었습니다.
- 사용자 역할별 조건부 렌더링, 리뷰 조건 분기 등을 통해 **UI/UX 설계 능력**을 강화했습니다.
- 다양한 상태 기반 흐름 (배송 상태, 리뷰 조건 등)을 관리하며 **상태 관리 및 로직 설계 역량**이 향상되었습니다.

