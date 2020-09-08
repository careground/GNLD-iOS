# 그느르다 
**그느르다**는 **스마트 화분을 이용한 독거노인 지원 플랫폼**입니다.

미세먼지, 일산화탄소, 온습도, 토양습도의 4개의 센서 데이터를 통해 사용자의 상태 및 집안 환경 모니터링합니다.

담당 생활 관리자는 웹페이지를 통해 측정된 데이터를 볼 수 있으며, 이를 기반으로 사용자를 케어합니다. 

사용자는 플렌테리어를 통한 정서적 함양 및 실시간 모니터링을 통한 위험 상황 방지 기능을 제공받을 수 있습니다.

앱(독거노인 용)의 기능은 다음과 같습니다.

- 그느르다 화분과 앱 블루투스 연결 

- 화분 센서에 감지된 데이터 확인 (온도, 미세먼지, 일산화탄소, 식물토양수분) 

- 위험이 감지되면 사용자에게 위험 푸쉬알림 전송
-  위험 푸쉬알림에 대해 "괜찮아요" 버튼을 누르면 위험리스트에서 제외 

웹(담당 생활 관리자 용)의 기능은 다음과 같습니다.

- 돌봄 대상 리스트 확인 (그느르다 화분을 배포받은 모든 사용자들에 대한 리스트)

-  위험 대상 리스트 확인 후 조치

  위험 기준 - 국내 기준 등급 지표에 따른 농도 수준을 따름

  - 미세먼지 (PM10) : 100(μg/m³)이상 
  - 유해가스(CO) : 10ppm이상 
  - 토양수분 : 40%이하 

## [ Architecture ]

![Architecture](https://github.com/careground/GNLD-iOS/blob/master/PublicData/architecture/%EC%9E%91%ED%92%88%EC%84%A4%EA%B3%84%EB%8F%84.png)



## [ WorkFlow ]

![WorkFlowApp](https://github.com/careground/GNLD-iOS/blob/master/PublicData/workflow/workflow_app.jpeg)

![WorkFlowWeb](https://github.com/careground/GNLD-iOS/blob/master/PublicData/workflow/workflow_web.jpeg)



## [ Develop Environment ]

- Language : **Swift 5**
- iOS Depolyment Target : **9.3**

## [ Library ]

1. Networking

- Moya
- SwiftyJSON

2. Push Alarm

- Firebase
  
