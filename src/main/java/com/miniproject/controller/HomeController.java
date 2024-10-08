package com.miniproject.controller;

import java.io.IOException;
import java.text.DateFormat;
import java.util.Date;
import java.util.Locale;

import javax.servlet.http.HttpSession;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;

import com.miniproject.util.PropertiesTask;

/**
 * Handles requests for the application home page.
 */
@Controller
public class HomeController {
	
	private static final Logger logger = LoggerFactory.getLogger(HomeController.class);
	
	/**
	 * Simply selects the home view to render by returning its name.
	 */
	@RequestMapping(value = "/", method = RequestMethod.GET)
	public String home(Locale locale, Model model, HttpSession ses) {
		logger.info("Welcome home! The client locale is {}.", locale);
		
		Date date = new Date();
		DateFormat dateFormat = DateFormat.getDateTimeInstance(DateFormat.LONG, DateFormat.LONG, locale);
		
		String formattedDate = dateFormat.format(date);
		
		model.addAttribute("serverTime", formattedDate );
		
		//if(ses.)
		
		return "index";
	}
	
	@RequestMapping(value="/exampleInterceptor")
	public void examInterceptor() {
		logger.info("examInterceptor() 호출!!!");
	}
	
	@RequestMapping(value="/example")
	public void testInterceptors() {
		logger.info("testInterceptors() 호출!!!");
	}
	
	@GetMapping("/callNaverAPIProp")
	public void callNaverAPIProp() throws IOException {
		String clientId = PropertiesTask.getPropertiesValue("naverapi.properties", "naver.clientId");
		logger.info("clientId : " + clientId);
	}
	
}
