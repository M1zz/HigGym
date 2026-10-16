//
//  HigGymFlags.swift
//  HigGym
//
//  원격 킬스위치 플래그. LeeoKit(LeeoRemoteFlags)이 FeedbackHub 의 CloudKit RemoteFlags 레코드에서 읽는다.
//  Dashboard: 레코드 타입 RemoteFlags / recordName flags_com.leeo.higgym / 필드 = rawValue (Int64, 1=켬 0=끔).
//  필드가 없거나 조회에 실패하면 켬으로 동작한다. 갱신은 백그라운드로 몇 시간 간격이라 즉시 전파되지 않는다.
//
//  ⚠️ rawValue 는 Dashboard 필드 이름과의 계약이다, 바꾸지 않는다.
//

import LeeoKit

enum HigGymFlag: String, LeeoRemoteFlag, CaseIterable {
    /// "즐겁게 쓰고 계신가요?" 만족도 질문. 레슨 도중 끼어들거나 잘못 뜨면 심사 없이 끈다.
    case satisfactionPromptEnabled
    /// 기능 안내 말풍선(TipKit). 화면을 가리거나 잘못된 자리에 뜨면 끈다.
    case featureTipsEnabled
}
