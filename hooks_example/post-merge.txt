#!/bin/sh
# 머지 후 자동화 작업

current_branch=$(git rev-parse --abbrev-ref HEAD)

echo "🎯 Post-merge 자동화 시작..."

# main 브랜치에 머지된 경우에만 태그 생성
if [ "$current_branch" = "main" ] || [ "$current_branch" = "master" ]; then

    if [ -f "tags/default.txt" ]; then
        echo "🏷️  태그 정보 파일 발견, 태그 생성 중..."

        # 새로운 형식으로 정보 읽기
        tag_name=$(grep "^name:" tags/default.txt | cut -d':' -f2)
        tag_message=$(grep "^message:" tags/default.txt | cut -d':' -f2)

        if [ -n "$tag_name" ]; then
            # 이미 같은 태그가 존재하는지 확인
            if git tag -l | grep -q "^$tag_name$"; then
                echo "⚠️  태그 '$tag_name'이 이미 존재합니다."
            else
                # 태그 메시지 구성
                current_date=$(date '+%Y-%m-%d %H:%M:%S')
                commit_hash=$(git rev-parse --short HEAD)

                # message가 비어있으면 기본 메시지 사용
                if [ -z "$tag_message" ]; then
                    tag_message="Android Release Build"
                fi

                full_message="$tag_message <br>
                생성 날짜: $current_date <br>
                커밋 해시: $commit_hash"

                echo "Created Tag: $tag_name"
                git tag -a "$tag_name" -m "$full_message"

                # Remote Push
                if git push origin "$tag_name"; then
                    echo "Tag '$tag_name' Remote Push Success"
                else
                    echo "Tag Push Fail Manual Command 'git push origin $tag_name'"
                fi

                # main 브랜치도 푸시 확인
                echo "Push Branch Check main..."
                git push origin "$current_branch"
            fi
        else
            echo "Error: Not Found TagName tags/default.txt"
        fi
    else
        echo "Error: Not Found File tags/default.txt"
    fi
else
    echo "TagCreate Skip"
fi

# 브랜치 정리
echo "Clear Branch..."
deleted_branch=$(git reflog | grep "checkout: moving from" | head -1 | awk '{print $6}')
if [ "$deleted_branch" != "main" ] && [ "$deleted_branch" != "master" ] && [ "$deleted_branch" != "develop" ] && [ "$deleted_branch" != "HEAD" ]; then
    if git branch -d "$deleted_branch" 2>/dev/null; then
        echo "🗑️  브랜치 '$deleted_branch' 자동 삭제 완료"
    else
        echo "ℹ️  브랜치 '$deleted_branch' 삭제 불가 (미머지 또는 보호된 브랜치)"
    fi
fi

echo "🎉 Post-merge 자동화 작업 완료!"