package com.miniproject.persistence;

import com.miniproject.model.LoginDTO;
import com.miniproject.model.MemberDTO;

public interface MemberDAO {
	// 유저의 userPoint를 수정하는 메서드
	int updateUserPoint(String userId)throws Exception;

	// 아이디 중복체크
	int selectDuplicateId(String tmpUserId) throws Exception;

	// 회원가입
	int insertMember(MemberDTO registerMember);

	// 로그인
	MemberDTO login(LoginDTO loginDTO);
}
