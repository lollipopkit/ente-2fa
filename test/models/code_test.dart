import 'package:ente_auth/data/models/code.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test("parseCodeFromRawData", () {
    final code1 = Code.fromRawData(
      "otpauth://totp/example%20finance%3Aee%40ff.gg?secret=ASKZNWOU6SVYAMVS",
    );
    expect(code1.issuer, "example finance", reason: "issuerMismatch");
    expect(code1.account, "ee@ff.gg", reason: "accountMismatch");
    expect(code1.secret, "ASKZNWOU6SVYAMVS");
  });

  test("parseDocumentedFormat", () {
    final code = Code.fromRawData(
      "otpauth://totp/testdata@ente.io?secret=ASKZNWOU6SVYAMVS&issuer=GitHub",
    );
    expect(code.issuer, "GitHub", reason: "issuerMismatch");
    expect(code.account, "testdata@ente.io", reason: "accountMismatch");
    expect(code.secret, "ASKZNWOU6SVYAMVS");
  });

  test("validateCount", () {
    final code = Code.fromRawData(
      "otpauth://hotp/testdata@ente.io?secret=ASKZNWOU6SVYAMVS&issuer=GitHub&counter=15",
    );
    expect(code.issuer, "GitHub", reason: "issuerMismatch");
    expect(code.account, "testdata@ente.io", reason: "accountMismatch");
    expect(code.secret, "ASKZNWOU6SVYAMVS");
    expect(code.counter, 15);
  });
//

  test("parseWithFunnyAccountName", () {
    final code = Code.fromRawData(
      "otpauth://totp/Mongo Atlas:Acc !@#444?algorithm=sha1&digits=6&issuer=Mongo Atlas&period=30&secret=NI4CTTFEV4G2JFE6",
    );
    expect(code.issuer, "Mongo Atlas", reason: "issuerMismatch");
    expect(code.account, "Acc !@#444", reason: "accountMismatch");
    expect(code.secret, "NI4CTTFEV4G2JFE6");
  });

  test("parseAndUpdateInChinese", () {
    const String rubberDuckQr =
        'otpauth://totp/%E6%A9%A1%E7%9A%AE%E9%B8%AD?secret=2CWDCK4EOIN5DJDRMYUMYBBO4MKSR5AX&issuer=ente.io';
    final code = Code.fromRawData(rubberDuckQr);
    expect(code.account, '橡皮鸭');
    final String updatedRawCode =
        code.copyWith(account: '伍迪', issuer: '鸭子').rawData;
    final updateCode = Code.fromRawData(updatedRawCode);
    expect(updateCode.account, '伍迪', reason: 'updated accountMismatch');
    expect(updateCode.issuer, '鸭子', reason: 'updated issuerMismatch');
  });
}
