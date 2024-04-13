// Function to check for the presence of "Thank you" in the page text
async function checkPageContent(){
    var text = document.body.innerText;
    let substring = "Register";
  
    //console.log("hello");
  
    if (text.toLowerCase().includes(substring.toLowerCase())) {
      console.log(window.location.toString());
  
      //console.log("yes");
      //console.log("Before getting URL");
      const url = window.location.toString();
      //console.log("After getting URL:", url);
  
  
      const data = {
        uRL: url,
      };
  
      await fetch("http://127.0.0.1:5005/mark_as_applied", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify(data),
      })
        .then((response) => {
          if (!response.ok) {
            throw new Error("Network response was not ok");
          }
          console.log("Data sent successfully");
          console.log(data);
        })
        .catch((error) => {
          console.error("Error sending data:", error);
        });
    } 
    else {
      console.log("not a post submission page");
    }
  }
  
  const config = { characterData: true, childList: true, subtree: true };
  const targetNode = document.body; //.getElementById("some-id");
  
  // Callback function to execute when mutations are observed
  const callback = (mutationList, observer) => {
    try {
      for (const mutation of mutationList) {
        if (mutation.type === "childList" || mutation.type === "subtree") {
          //console.log("hey");
          checkPageContent();
        }
      }
      checkPageContent();
    } catch (error) {
      console.error("Error in observer callback:", error);
    }
  };
  
  // Create an observer instance linked to the callback function
  const observer = new MutationObserver(callback);
  //console.log("Content script loaded");
  
  // Start observing the target node for configured mutations
  observer.observe(targetNode, config);
  
  // Later, you can stop observing
  //observer.disconnect();
  