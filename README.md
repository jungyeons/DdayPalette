# DdayPalette

macOS용 자격증 D-day 기록 앱입니다. 여러 자격증 시험일을 색상 카드로 저장하고, WidgetKit 데스크탑 위젯으로 남은 날짜를 볼 수 있습니다.

## 기능

- 자격증/시험 D-day 추가, 편집, 삭제
- 색상 팔레트와 SF Symbol 아이콘 선택
- 중요 표시, 다가오는 시험/지난 기록 필터
- macOS 데스크탑 위젯 지원
  - 작은 위젯: 대표 D-day 카드
  - 중간/큰 위젯: 여러 D-day 목록

## 실행

1. `DdayPalette.xcodeproj`를 Xcode로 엽니다.
2. `DdayPalette` 타겟과 `DdayPaletteWidgetExtension` 타겟의 Signing & Capabilities에서 Team을 본인 Apple ID로 선택합니다.
3. App Groups에 `group.com.jungyeons.DdayPalette`가 켜져 있는지 확인합니다.
4. 앱을 실행하고 시험일을 추가합니다.
5. 바탕화면 우클릭 또는 알림 센터에서 위젯 편집을 열고 `Dday Palette` 위젯을 추가합니다.

## GitHub에 올리기

`gh` 로그인이 되어 있다면:

```sh
cd /Users/jungyeons/Documents/GitHub/DdayPalette
gh auth login
gh repo create DdayPalette --public --source=. --remote=origin --push
```

이미 GitHub에서 빈 저장소를 만들었다면:

```sh
cd /Users/jungyeons/Documents/GitHub/DdayPalette
git remote add origin https://github.com/YOUR_ID/DdayPalette.git
git push -u origin main
```
