
<div align="center">
  <img src="https://github.com/leejh8997/ARcohol/blob/developer/assets/ARcohol4.png?raw=true" width="300"/>
</div>

<div style="text-align:left;">
<h2 style="border-bottom: 1px solid #d8dee4; color: #282d33;">💡 프로젝트 소개 </h2>
<div>Flutter 기반 칵테일 레시피/커머스 앱으로, 마이바(MyBar) 기능과 AR 시연, 리뷰 및 주문까지 가능한 올인원 플랫폼입니다.</div>
<div>사용자는 자신이 가진 재료 기반으로 레시피 추천을 받고, 제품 구매 및 리뷰 작성이 가능합니다.</div>
<div>Firestore를 이용한 데이터베이스 설계와 Flutter UI를 통한 직관적인 사용자 경험을 제공하는 앱입니다.</div>
</div>

<div style="text-align:left;">
<h2 style="border-bottom: 1px solid #d8dee4; color: #282d33;"> 🗓 개발 기간 </h2>  
<ul>
<li><h4>2025. 06. 09 ~ 2025. 06. 26</h4></li>
<li>기획 및 Firestore 구조 설계</li>
<li>Flutter 기반 UI/UX 개발 및 기능 구현</li>
<li>기능별 테스트 및 버그 수정</li>
</ul>
</div>

<div style="text-align:left;">
<h2 tabindex="-1" class="heading-element" dir="auto">👨‍👩‍👦‍👦 팀원 구성</h2>
<table>
<tr><th>이름</th><th>GitHub 프로필</th><th>역할</th></tr>
<tr><td>이재형</td><td>https://github.com/leejh8997</td><td>팀장</td></tr>
<tr><td>박재원</td><td>https://github.com/latte28</td><td>팀원</td></tr>
<tr><td>이태훈</td><td>https://github.com/Taehun92</td><td>팀원</td></tr>
<tr><td>천상욱</td><td>https://github.com/chonsa29</td><td>팀원</td></tr>
</table>
</div>

<div style="text-align:left;">
<h2 style="border-bottom: 1px solid #d8dee4; color: #282d33;">📕 발표 PPT</h2>
<a href="https://drive.google.com/file/d/1S54vN3MGMAPsJRxfwo8K9Y5LPi9_-tiM/view?usp=drive_link">▶ Kapture 발표 PPT</a>
</div>

<div style="text-align:left;">
<h2 style="border-bottom: 1px solid #d8dee4; color: #282d33;">🎞 시연 영상</h2>
<a href="https://youtu.be/nYb7iXMzafA">▶ Kapture 시연 영상</a>
</div>

<div style="text-align:left;">
<h2 style="border-bottom: 1px solid #d8dee4; color: #282d33;">🧑‍💼 역할 분담</h2>
<h3>😎 이재형 (팀장)</h3>
<ul>
<li>유저 마이페이지, 관리자 페이지(상품, 가이드, 주문, 고객 관련 관리)</li>
<li>정보 수정 및 유효성 검사, 프로필 이미지 관리</li>
</ul>

<h3>😎 박재원</h3>
<ul>
<li>로그인, 회원가입, 요청 게시판, 가이드 마이페이지, 헤더/푸터</li>
<li>이메일 인증, 중복 검사, 소셜 로그인, 모달 처리 등</li>
</ul>

<h3>😎 이태훈</h3>
<ul>
<li>메인 페이지, 상품 등록/수정/디자인, 관광지 보기, 장바구니 기능</li>
<li>API 연동(기상청, 챗봇 등), 여행지 필터 추가</li>
</ul>

<h3>😎 천상욱</h3>
<ul>
<li>마이페이지(정보수정, 주소관리), 공지사항 관리, 사용자 인증 흐름</li>
</ul>
</div>

<div style="text-align:left;">
<h2 style="color: #282d33;"> 🛠️ 사용 언어 및 기술 스택 </h2>
<div style="margin: 0 auto; text-align: left;">
<img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white">
<img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white">
<img src="https://img.shields.io/badge/Android Studio-3DDC84?style=for-the-badge&logo=androidstudio&logoColor=white">
<img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black">
<img src="https://img.shields.io/badge/Firestore-FFA000?style=for-the-badge&logo=firebase&logoColor=white">
<img src="https://img.shields.io/badge/Firebase Auth-FF6D00?style=for-the-badge&logo=firebase&logoColor=white">
<img src="https://img.shields.io/badge/Firebase Storage-019CFE?style=for-the-badge&logo=google-cloud&logoColor=white">
</div>
</div>

<div style="text-align:left;">
<h2 style="border-bottom: 1px solid #d8dee4; color: #282d33;">📄 주요 기능 및 페이지</h2>
<ul>
<li>회원가입/로그인: Firebase Auth 기반 이메일 인증 로그인</li>
<li>홈: 랜덤 배너/추천 레시피/인기 레시피/상품 목록 표시 (5개 + more)</li>
<li>마이바: 인벤토리 기반 추천 레시피 표시</li>
<li>상품: 상세 페이지/장바구니 담기/바로 구매 가능</li>
<li>결제: Firestore에 주문 문서 저장, 배송지 입력 및 총 결제 금액 표시</li>
<li>주문 내역: 결제일자/상태/제품 정보 확인 및 리뷰 작성</li>
<li>주문 취소/교환: 상태에 따른 분기 처리 및 사유 입력</li>
<li>AR 기능: 카메라 기반 재료 비율 시각화 예정</li>
</ul>
</div>

<div style="text-align:left;">
<h2 style="border-bottom: 1px solid #d8dee4; color: #282d33;">🎇 프로젝트 후기</h2>
<ul>
<li>실시간 상태 관리, 조건부 렌더링 등 다양한 상태 분기를 경험</li>
<li>Firebase 기반 NoSQL 설계와 구조화 경험 강화</li>
<li>Flutter UI 설계와 페이지 간 이동 흐름 구성에 대한 실전 감각 향상</li>
</ul>
</div>
