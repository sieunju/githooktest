#!/bin/sh
# 머지 후 자동화 작업

current_branch=$(git rev-parse --abbrev-ref HEAD)

echo "Post-merge Start"

# main 브랜치에 머지된 경우에만 태그 생성
if [ "$current_branch" = "main" ] || [ "$current_branch" = "master" ]; then

    if [ -f "tags/default.txt" ]; then
        echo "Detector Tag, Tag Created..."

        # 새로운 형식으로 정보 읽기
        tag_name=$(grep "^name:" tags/default.txt | cut -d':' -f2)
        tag_message=$(grep "^message:" tags/default.txt | cut -d':' -f2)

        if [ -n "$tag_name" ]; then
            # 이미 같은 태그가 존재하는지 확인
            if git tag -l | grep -q "^$tag_name$"; then
                echo "The same tag already exists: '$tag_name'"
            else
                # 태그 메시지 구성
                current_date=$(date '+%Y-%m-%d %H:%M:%S')
                commit_hash=$(git rev-parse --short HEAD)

                # message가 비어있으면 기본 메시지 사용
                if [ -z "$tag_message" ]; then
                    tag_message="No Custom Message"
                fi

                # 실제 줄바꿈 사용
                full_message="$tag_message

생성 날짜: $current_date
커밋 해시: $commit_hash
브랜치: $current_branch"

                echo "Created Tag: $tag_name"
                git tag -a "$tag_name" -m "$full_message"

                # Remote Push
                echo "Push Tag to Remote..."
                if git push origin "$tag_name"; then
                    echo "Tag '$tag_name' Remote Push Success"
                else
                    echo "Tag Push Fail Manual Command: 'git push origin $tag_name'"
                fi

                # main 브랜치도 푸시 확인
                echo "Push Branch Check main..."
                if git push origin "$current_branch"; then
                    echo "Branch Push Success"
                else
                    echo "Branch Push Fail"
                fi
            fi
        else
            echo "Error: Not Found TagName in tags/default.txt"
        fi
    else
        echo "Error: Not Found File tags/default.txt"
    fi
else
    echo "TagCreate Skip (Not main branch)"
fi

# 브랜치 정리
echo "Clear Branch..."
deleted_branch=$(git reflog | grep "checkout: moving from" | head -1 | awk '{print $6}')
if [ "$deleted_branch" != "main" ] && [ "$deleted_branch" != "master" ] && [ "$deleted_branch" != "develop" ] && [ "$deleted_branch" != "HEAD" ]; then
    if git branch -d "$deleted_branch" 2>/dev/null; then
        echo "Delete Branch '$deleted_branch' Success"
    else
        echo "Delete Branch '$deleted_branch' Fail (Unmerged or Protected)"
    fi
else
    echo "Branch Delete Skip (Protected branch)"
fi

echo "Post-merge Completed"