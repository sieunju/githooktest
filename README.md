# githooktest

# tag version update
### Release 로 빌드한경우 버전명 코드 셋팅되도록 처리
```shell
./gradlew updateTagsFile
```
### Detail
```groovy
afterEvaluate {
    tasks.matching { task ->
        task.name.contains('Release')
    }.configureEach { task ->
        if (task.name.startsWith('assemble') || task.name.startsWith('bundle')) {
            task.finalizedBy updateTagsFile
            task.doFirst {
                println "🚀 Task updateTagsFile"
            }
            task.doLast {
                println "✅ Task updateTagsFile"
            }
        }
    }
}
```

# hooks 권한 설정
```shell
chmod +x .git/hooks/post-merge
chmod +x .git/hooks/pre-push
```

# Hooks Example 파일 옮기기
```shell
cp ./hooks_example/post-merge .git/hooks/post-merge
cp ./hooks_example/pre-push .git/hooks/pre-push
```

# Hooks Result
- 작업을 진행한후 merge 할때
  - hooks_example/post-merge 참고
- main, master 브렌치에 push 를 할때 자동 태그 생성
  - hooks_example/pre-push 참고

> 이런건 역시..클선생이 최고다. 