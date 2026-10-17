import Foundation

/// 번들 콘텐츠(entries.json · mistakes.json)를 기기 언어로 읽는다.
///
/// 콘텐츠의 원문은 한국어 JSON 하나다(원본 문서 · Tools/ 의 생성기가 만든다). 번역은 JSON 을 언어마다
/// 복제하지 않고 `Content.xcstrings` 표에 **원문 문장 → 번역** 으로 둔다. 원문이 바뀌면 그 문장만 표에서
/// 빈칸이 되고, `Tools/sync_content_strings.py` 가 그 빈칸을 알려 준다.
///
/// 읽을 때 JSON 의 모든 문자열 가운데 한글이 든 것만 표에서 찾아 바꾼 뒤 디코딩한다.
/// id · URL · 색인 같은 값은 한글이 없으니 그대로 지나간다.
enum ContentLocalization {
    static let table = "Content"

    /// 번들의 JSON 을 읽어 번역을 입히고 디코딩한다. 실패하면 이유를 로그에 남기고 nil.
    static func decode<T: Decodable>(_ type: T.Type, resource: String, bundle: Bundle = .main) -> T? {
        let signposter = HigGymLog.signposter
        let state = signposter.beginInterval("콘텐츠 읽기", "\(resource, privacy: .public)")
        defer { signposter.endInterval("콘텐츠 읽기", state) }

        guard let url = bundle.url(forResource: resource, withExtension: "json") else {
            HigGymLog.content.fault("\(resource, privacy: .public).json 이 번들에 없습니다")
            return nil
        }
        do {
            let data = try Data(contentsOf: url)
            let localized = try localize(data, bundle: bundle)
            return try JSONDecoder().decode(T.self, from: localized)
        } catch {
            HigGymLog.content.fault("\(resource, privacy: .public).json 을 읽지 못했습니다: \(String(describing: error), privacy: .public)")
            return nil
        }
    }

    /// JSON 데이터 안의 한글 문자열을 번역으로 바꾼 데이터.
    static func localize(_ data: Data, bundle: Bundle = .main) throws -> Data {
        let object = try JSONSerialization.jsonObject(with: data)
        let translated = translate(object, bundle: bundle)
        return try JSONSerialization.data(withJSONObject: translated)
    }

    /// 한 문장을 기기 언어로. 표에 없으면 원문 그대로 둔다.
    static func string(_ korean: String, bundle: Bundle = .main) -> String {
        guard containsHangul(korean) else { return korean }
        return bundle.localizedString(forKey: korean, value: korean, table: table)
    }

    private static func translate(_ value: Any, bundle: Bundle) -> Any {
        switch value {
        case let text as String:
            return string(text, bundle: bundle)
        case let array as [Any]:
            return array.map { translate($0, bundle: bundle) }
        case let dictionary as [String: Any]:
            return dictionary.mapValues { translate($0, bundle: bundle) }
        default:
            return value
        }
    }

    static func containsHangul(_ text: String) -> Bool {
        text.unicodeScalars.contains { (0xAC00...0xD7A3).contains($0.value) || (0x3131...0x318E).contains($0.value) }
    }
}
