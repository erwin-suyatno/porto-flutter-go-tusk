package controllers

import (
	"net/http"
	"os"
	"strconv"
	"tusk/model"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

type TaskController struct {
	DB *gorm.DB
}

func (t *TaskController) CreateTask(c *gin.Context) {
	task := model.Task{}
	errBindJson := c.ShouldBindJSON(&task)
	if errBindJson != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": errBindJson.Error(),
		})
		return
	}

	task.Status = "Queue"
	errDB := t.DB.Create(&task).Error
	if errDB != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": errDB.Error(),
		})
		return
	}
	c.JSON(http.StatusCreated, task)
}

func (t *TaskController) DeleteTask(c *gin.Context) {
	id := c.Param("id")
	task := model.Task{}

	if err := t.DB.First(&task, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{
			"error": err.Error(),
		})
		return
	}

	errDB := t.DB.Delete(&model.Task{}, id).Error
	if errDB != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": errDB.Error(),
		})
		return
	}

	if task.Attachment != "" {
		os.Remove("assets/" + task.Attachment)
	}

	c.JSON(http.StatusOK, "Deleted successfully")
}

func (t *TaskController) SubmitTask(c *gin.Context) {
	task := model.Task{}
	id := c.Param("id")
	submitDate := c.PostForm("submitDate")
	file, errFile := c.FormFile("attachment")

	if errFile != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": errFile.Error(),
		})
		return
	}

	if err := t.DB.First(&task, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{
			"error": err.Error(),
		})
		return
	}

	// remove old attachment
	attachment := task.Attachment
	fileInfo, _ := os.Stat("assets/" + attachment)
	if fileInfo != nil {
		os.Remove("assets/" + attachment)
	}

	// upload new attachment
	attachment = file.Filename
	errSave := c.SaveUploadedFile(file, "assets/"+attachment)

	if errSave != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": errSave.Error(),
		})
		return
	}

	errDB := t.DB.Model(&model.Task{}).Where("id = ?", id).Updates(model.Task{
		Status:     "Review",
		Attachment: attachment,
		SubmitDate: submitDate,
	}).Error
	if errDB != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": errDB.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, "Submit to review")
}

func (t *TaskController) RejectTask(c *gin.Context) {
	task := model.Task{}
	id := c.Param("id")
	reason := c.PostForm("reason")
	rejectedDate := c.PostForm("rejectedDate")

	if err := t.DB.First(&task, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{
			"error": err.Error(),
		})
		return
	}

	errDB := t.DB.Where("id = ?", id).Updates(model.Task{
		Status:       "Rejected",
		Reason:       reason,
		RejectedDate: rejectedDate,
	}).Error
	if errDB != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": errDB.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, "Rejected")
}

func (t *TaskController) FixTask(c *gin.Context) {
	id := c.Param("id")
	revision, errConv := strconv.Atoi(c.PostForm("revision"))

	if errConv != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": errConv.Error(),
		})
		return
	}

	if err := t.DB.First(&model.Task{}, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{
			"error": err.Error(),
		})
		return
	}

	errDB := t.DB.Where("id = ?", id).Updates(model.Task{
		Status:   "Queue",
		Revision: int8(revision),
	}).Error
	if errDB != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": errDB.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, "Fix to Queue")
}

func (t *TaskController) ApproveTask(c *gin.Context) {
	task := model.Task{}
	id := c.Param("id")
	approvedDate := c.PostForm("approvedDate")

	if err := t.DB.First(&task, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{
			"error": err.Error(),
		})
		return
	}

	errDB := t.DB.Where("id = ?", id).Updates(model.Task{
		Status:       "Approved",
		ApprovedDate: approvedDate,
	}).Error
	if errDB != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": errDB.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, "Approve")
}

func (t *TaskController) GetTask(c *gin.Context) {
	task := model.Task{}
	id := c.Param("id")

	if err := t.DB.Preload("User").First(&task, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{
			"error": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, task)
}

func (t *TaskController) NeedToBeReviewed(c *gin.Context) {
	tasks := []model.Task{}

	err := t.DB.Preload("User").Where("status=?", "Review").Order("submit_date ASC").Limit(2).Find(&tasks).Error

	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{
			"error": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, tasks)
}

func (t *TaskController) ProgressTasks(c *gin.Context) {
	tasks := []model.Task{}
	userId := c.Param("userId")

	if err := t.DB.Where(
		"(status!=? AND user_id=?) OR (revision!=? AND user_id=?)", "Queue", userId, 0, userId,
	).Order("updated_at DESC").Find(&tasks).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{
			"error": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, tasks)
}

func (t *TaskController) StatisticTask(c *gin.Context) {
	userId := c.Param("userId")

	stat := []map[string]interface{}{}
	if err := t.DB.Model(model.Task{}).Select("status, count(status) as total").Where(
		"user_id=?", userId,
	).Group("status").Find(&stat).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{
			"error": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, stat)
}

func (t *TaskController) FindByUserAndStatus(c *gin.Context) {
	tasks := []model.Task{}
	userId := c.Param("userId")
	status := c.Param("status")

	if err := t.DB.Where("user_id = ? AND status = ?", userId, status).Find(&tasks).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{
			"error": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, tasks)
}
