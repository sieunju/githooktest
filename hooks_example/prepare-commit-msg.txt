#!/bin/sh
# 머지 커밋 메시지 자동 생성

if [ "$2" = "merge" ]; then
    current_branch=$(git rev-parse --abbrev-ref HEAD)

    # 머지되는 브랜치명 추출
    merging_branch=$(git log --oneline -1 MERGE_HEAD | cut -d' ' -f2- | sed 's/^origin\///')

    # 머지되는 브랜치의 커밋 메시지들 수집
    commit_messages=$(git log --pretty=format:"• %s" HEAD..MERGE_HEAD)
    commit_count=$(git rev-list --count HEAD..MERGE_HEAD)

    # 새로운 머지 커밋 메시지 생성
    cat > "$1" << EOF
🔀 Merge: $merging_branch -> $current_branch

📊 총 $commit_count개의 커밋 포함:
$commit_messages

⏰ 머지 시각: $(date '+%Y-%m-%d %H:%M:%S')
EOF

    echo "✅ 머지 커밋 메시지 자동 생성됨"
fi