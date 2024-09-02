package com.miniproject.persistence;

import javax.inject.Inject;

import org.apache.ibatis.session.SqlSession;
import org.springframework.stereotype.Repository;

@Repository
public class MemberDAOImpl implements MemberDAO{

	@Inject
	SqlSession ses;
	
	private String ns = "com.miniproject.mappers.memberMapper.";
	
	@Override
	public int updateUserPoint(String userId) throws Exception {

		return ses.update(ns + "updateUserPoint", userId);
	}

}
