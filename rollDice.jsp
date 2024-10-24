<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // Generate a random dice roll (1 to 6)
    int diceValue = (int)(Math.random() * 6) + 1;

    // Send the dice roll result back as JSON
    out.println("{ \"diceValue\": " + diceValue + " }");
%>
